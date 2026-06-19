import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backendConfigProvider = Provider<BackendConfig>((ref) {
  return BackendConfig.fromEnvironment();
});

class BackendConfig {
  const BackendConfig({
    required this.baseUrl,
    this.useFirebaseBackend = false,
    this.useSupabaseBackend = false,
    this.supabaseUrl = '',
    this.supabasePublishableKey = '',
    this.supabaseAuthRedirectUrl = _productionAuthRedirectUrl,
  });

  factory BackendConfig.fromEnvironment() {
    return const BackendConfig(
      baseUrl: String.fromEnvironment('API_BASE_URL'),
      useFirebaseBackend: bool.fromEnvironment(
        'USE_FIREBASE_BACKEND',
      ),
      useSupabaseBackend: bool.fromEnvironment(
        'USE_SUPABASE_BACKEND',
      ),
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
      supabaseAuthRedirectUrl: String.fromEnvironment(
        'SUPABASE_AUTH_REDIRECT_URL',
        defaultValue: _productionAuthRedirectUrl,
      ),
    );
  }

  static const _productionAuthRedirectUrl =
      'https://cool-duckanoo-d28d04.netlify.app/';

  final String baseUrl;
  final bool useFirebaseBackend;
  final bool useSupabaseBackend;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String supabaseAuthRedirectUrl;

  bool get requiresAuth => useSupabaseBackend || useFirebaseBackend;

  Uri get baseUri {
    final trimmedBaseUrl = baseUrl.trim();
    if (trimmedBaseUrl.isEmpty) {
      throw const BackendConfigException(
        'API_BASE_URL is required when USE_FIREBASE_BACKEND=true.',
      );
    }

    final uri = Uri.tryParse(trimmedBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw BackendConfigException('Invalid API_BASE_URL: $baseUrl');
    }

    return uri;
  }

  Uri get supabaseUri {
    final trimmedUrl = supabaseUrl.trim();
    if (trimmedUrl.isEmpty) {
      throw const BackendConfigException(
        'SUPABASE_URL is required when USE_SUPABASE_BACKEND=true.',
      );
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw BackendConfigException('Invalid SUPABASE_URL: $supabaseUrl');
    }

    return uri;
  }

  String get requiredSupabasePublishableKey {
    final trimmedKey = supabasePublishableKey.trim();
    if (trimmedKey.isEmpty) {
      throw const BackendConfigException(
        'SUPABASE_PUBLISHABLE_KEY is required when USE_SUPABASE_BACKEND=true.',
      );
    }

    return trimmedKey;
  }

  Uri get supabaseAuthRedirectUri {
    final webOriginUri = _currentWebOriginUri();
    if (webOriginUri != null) {
      return webOriginUri;
    }

    final trimmedUrl = supabaseAuthRedirectUrl.trim();
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw BackendConfigException(
        'Invalid SUPABASE_AUTH_REDIRECT_URL: $supabaseAuthRedirectUrl',
      );
    }

    return uri;
  }

  Uri? _currentWebOriginUri() {
    if (!kIsWeb) {
      return null;
    }

    final base = Uri.base;
    if ((base.scheme != 'https' && base.scheme != 'http') ||
        base.host.isEmpty) {
      return null;
    }

    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/',
    );
  }
}

class BackendConfigException implements Exception {
  const BackendConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
