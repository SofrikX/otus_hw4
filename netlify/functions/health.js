const DEFAULT_TIMEOUT_MS = 5000;
const APP_VERSION = process.env.APP_VERSION || process.env.COMMIT_REF || 'unknown';

function log(level, message, details = {}) {
  const safeDetails = sanitizeLogDetails({
    service: 'petconnect-health',
    event: 'health_check',
    ...details,
    timestamp: new Date().toISOString(),
  });
  const consoleLevel = level === 'warning' ? 'warn' : level;

  // Structured logs for Netlify Functions. Never include env values or keys.
  console[consoleLevel](JSON.stringify({ level, message, ...safeDetails }));
}

function sanitizeLogDetails(details) {
  return Object.fromEntries(
    Object.entries(details)
      .filter(([key]) => !isSensitiveLogKey(key))
      .map(([key, value]) => [key, sanitizeLogValue(value)]),
  );
}

function isSensitiveLogKey(key) {
  const normalized = key.toLowerCase();
  return normalized.includes('token') ||
    normalized.includes('password') ||
    normalized.includes('secret') ||
    normalized.includes('apikey') ||
    normalized.includes('api_key') ||
    normalized.includes('authorization') ||
    normalized.includes('cookie') ||
    normalized.includes('email') ||
    normalized.includes('user_id') ||
    normalized.endsWith('_id') ||
    normalized.includes('supabase_url') ||
    normalized.includes('publishable_key') ||
    normalized.includes('service_role');
}

function sanitizeLogValue(value) {
  if (value === null || value === undefined) {
    return value;
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return value;
  }

  const stringValue = String(value).trim();
  return stringValue.length > 120 ? `${stringValue.slice(0, 120)}...` : stringValue;
}

function json(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store, max-age=0',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
    },
    body: JSON.stringify(body),
  };
}

function createCheck(status, message, extra = {}) {
  return {
    status,
    message,
    ...extra,
  };
}

function isReachableStatus(status) {
  return status >= 200 && status < 500;
}

function normalizeSupabaseUrl(rawUrl) {
  if (!rawUrl) {
    return null;
  }

  const parsed = new URL(rawUrl);
  if (!['https:', 'http:'].includes(parsed.protocol) || !parsed.hostname) {
    throw new Error('SUPABASE_URL must be an absolute HTTP(S) URL.');
  }

  parsed.pathname = parsed.pathname.replace(/\/+$/, '');
  parsed.search = '';
  parsed.hash = '';

  return parsed;
}

async function fetchWithTimeout(url, options = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DEFAULT_TIMEOUT_MS);

  try {
    return await fetch(url, {
      ...options,
      signal: controller.signal,
    });
  } finally {
    clearTimeout(timeout);
  }
}

async function checkEndpoint(name, url, options = {}) {
  const startedAt = Date.now();

  try {
    const response = await fetchWithTimeout(url, options);
    const durationMs = Date.now() - startedAt;

    if (isReachableStatus(response.status)) {
      log('info', `${name} endpoint responded`, {
        check: name,
        httpStatus: response.status,
        durationMs,
      });

      return createCheck('ok', 'Endpoint responded.', {
        httpStatus: response.status,
        durationMs,
      });
    }

    log('warning', `${name} endpoint returned an upstream error`, {
      check: name,
      httpStatus: response.status,
      durationMs,
    });

    return createCheck('degraded', 'Endpoint returned an upstream error.', {
      httpStatus: response.status,
      durationMs,
    });
  } catch (error) {
    const durationMs = Date.now() - startedAt;
    const errorName = error && error.name ? error.name : 'Error';

    log('error', `${name} endpoint request failed`, {
      check: name,
      errorName,
      durationMs,
    });

    return createCheck('error', 'Endpoint request failed.', {
      errorName,
      durationMs,
    });
  }
}

async function checkPostsQuery(supabaseUrl, publishableKey) {
  if (!publishableKey) {
    log('warning', 'Optional posts query skipped because no publishable key is configured', {
      check: 'supabase_posts_query',
    });

    return createCheck('skipped', 'Optional posts query skipped: publishable key is not configured.');
  }

  const startedAt = Date.now();
  const url = new URL('/rest/v1/posts', supabaseUrl);
  url.searchParams.set('select', 'id');
  url.searchParams.set('limit', '1');

  try {
    const response = await fetchWithTimeout(url, {
      headers: {
        apikey: publishableKey,
        Authorization: `Bearer ${publishableKey}`,
        Accept: 'application/json',
      },
    });
    const durationMs = Date.now() - startedAt;

    if (response.ok) {
      log('info', 'Optional posts query succeeded', {
        check: 'supabase_posts_query',
        httpStatus: response.status,
        durationMs,
      });

      return createCheck('ok', 'Optional posts query succeeded.', {
        httpStatus: response.status,
        durationMs,
      });
    }

    if (response.status === 401 || response.status === 403) {
      log('warning', 'Optional posts query was blocked by RLS or API grants', {
        check: 'supabase_posts_query',
        httpStatus: response.status,
        durationMs,
      });

      return createCheck('skipped', 'Optional posts query blocked by RLS/API grants.', {
        httpStatus: response.status,
        durationMs,
      });
    }

    log('warning', 'Optional posts query returned a non-success status', {
      check: 'supabase_posts_query',
      httpStatus: response.status,
      durationMs,
    });

    return createCheck('degraded', 'Optional posts query returned a non-success status.', {
      httpStatus: response.status,
      durationMs,
    });
  } catch (error) {
    const durationMs = Date.now() - startedAt;
    const errorName = error && error.name ? error.name : 'Error';

    log('warning', 'Optional posts query failed', {
      check: 'supabase_posts_query',
      errorName,
      durationMs,
    });

    return createCheck('degraded', 'Optional posts query failed.', {
      errorName,
      durationMs,
    });
  }
}

function summarizeStatus(checks) {
  const requiredChecks = Object.entries(checks).filter(([, check]) => check.status !== 'skipped');

  if (requiredChecks.some(([, check]) => check.status === 'error')) {
    return 'error';
  }

  if (requiredChecks.some(([, check]) => check.status === 'degraded')) {
    return 'degraded';
  }

  return 'ok';
}

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return json(204, {});
  }

  if (event.httpMethod !== 'GET') {
    return json(405, {
      status: 'error',
      timestamp: new Date().toISOString(),
      checks: {
        method: createCheck('error', 'Only GET is supported.'),
      },
      version: APP_VERSION,
    });
  }

  const checks = {
    app: createCheck('ok', 'Netlify Function is reachable.'),
  };

  let supabaseUrl = null;

  try {
    supabaseUrl = normalizeSupabaseUrl(process.env.SUPABASE_URL);
    checks.supabase_url = supabaseUrl
      ? createCheck('ok', 'Supabase URL is configured.')
      : createCheck('error', 'SUPABASE_URL is not configured.');
  } catch (error) {
    checks.supabase_url = createCheck('error', 'SUPABASE_URL is invalid.');
    log('error', 'Invalid Supabase URL configuration', {
      check: 'supabase_url',
      errorName: error.name,
    });
  }

  if (supabaseUrl) {
    checks.supabase_auth = await checkEndpoint(
      'supabase_auth',
      new URL('/auth/v1/health', supabaseUrl),
      { headers: { Accept: 'application/json' } },
    );

    checks.supabase_rest = await checkEndpoint(
      'supabase_rest',
      new URL('/rest/v1/', supabaseUrl),
      { headers: { Accept: 'application/json' } },
    );

    checks.supabase_posts_query = await checkPostsQuery(
      supabaseUrl,
      process.env.SUPABASE_HEALTH_PUBLISHABLE_KEY || process.env.SUPABASE_PUBLISHABLE_KEY,
    );
  } else {
    checks.supabase_auth = createCheck('error', 'Skipped because SUPABASE_URL is missing or invalid.');
    checks.supabase_rest = createCheck('error', 'Skipped because SUPABASE_URL is missing or invalid.');
    checks.supabase_posts_query = createCheck('skipped', 'Skipped because SUPABASE_URL is missing or invalid.');
  }

  const status = summarizeStatus(checks);
  const statusCode = status === 'error' ? 503 : 200;
  const response = {
    status,
    timestamp: new Date().toISOString(),
    checks,
    version: APP_VERSION,
  };

  log(status === 'error' ? 'error' : status === 'degraded' ? 'warning' : 'info', 'Health check completed', {
    healthStatus: status,
    statusCode,
  });

  return json(statusCode, response);
};
