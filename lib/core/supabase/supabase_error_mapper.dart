import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_logger.dart';
import '../network/api_error.dart';

const _logger = AppLogger(component: 'supabase');

Future<T> guardSupabaseOperation<T>({
  required String operation,
  required Future<T> Function() action,
}) async {
  try {
    return await action();
  } on ApiException catch (error) {
    logSupabaseError(operation: operation, error: error);
    rethrow;
  } on AuthException catch (error) {
    final mapped = mapSupabaseAuthException(error);
    logSupabaseError(operation: operation, error: mapped);
    throw mapped;
  } on PostgrestException catch (error) {
    final mapped = mapSupabasePostgrestException(error);
    logSupabaseError(operation: operation, error: mapped);
    throw mapped;
  } on FormatException catch (error) {
    final mapped = ApiUnexpectedException(
      statusCode: 500,
      code: 'invalid-supabase-response',
      message: error.message,
    );
    logSupabaseError(operation: operation, error: mapped);
    throw mapped;
  } on Object catch (error) {
    if (error is Error) {
      rethrow;
    }

    final mapped = looksLikeNetworkFailure(error)
        ? const ApiNetworkException()
        : ApiUnexpectedException(
            statusCode: 500,
            code: 'unknown-error',
            message: error.runtimeType.toString(),
          );
    logSupabaseError(operation: operation, error: mapped);
    throw mapped;
  }
}

ApiException mapSupabaseAuthException(AuthException error) {
  final statusCode = int.tryParse(error.statusCode ?? '');
  final code = error.code ?? 'auth-error';
  final message = error.message;
  final lowerMessage = message.toLowerCase();

  if (error.runtimeType.toString() == 'AuthRetryableFetchException' ||
      statusCode == null ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('failed host lookup') ||
      lowerMessage.contains('xmlhttprequest error')) {
    return const ApiNetworkException(
      message: 'Supabase Auth is not reachable.',
    );
  }
  if (statusCode == 401 ||
      code == 'invalid_credentials' ||
      lowerMessage.contains('invalid login credentials')) {
    return ApiUnauthorizedException(message: message, code: code);
  }
  if (statusCode == 403) {
    return ApiForbiddenException(message: message, code: code);
  }
  if (statusCode == 404) {
    return ApiNotFoundException(message: message, code: code);
  }
  if (statusCode == 400 ||
      code == 'validation_failed' ||
      code == 'weak_password' ||
      lowerMessage.contains('email') ||
      lowerMessage.contains('password') ||
      lowerMessage.contains('already registered')) {
    return ApiValidationException(message: message, code: code);
  }
  if (statusCode >= 500) {
    return ApiServerException(
      message: message,
      statusCode: statusCode,
      code: code,
    );
  }

  return ApiUnexpectedException(
    statusCode: statusCode,
    code: code,
    message: message,
  );
}

ApiException mapSupabasePostgrestException(PostgrestException error) {
  final code = postgrestCode(error);
  final message = error.message;
  final lowerMessage = message.toLowerCase();

  if (code == '42501' ||
      lowerMessage.contains('row-level security') ||
      lowerMessage.contains('permission denied')) {
    return ApiForbiddenException(message: message, code: code);
  }
  if (code == '401' || code == 'PGRST301') {
    return ApiUnauthorizedException(message: message, code: code);
  }
  if (code == 'PGRST116' || code == '406' || lowerMessage.contains('0 rows')) {
    return ApiNotFoundException(message: message, code: code);
  }
  if (_isValidationPostgrestCode(code)) {
    return ApiValidationException(message: message, code: code);
  }
  if (code.startsWith('PGRST') || code.startsWith('PT')) {
    return ApiUnexpectedException(
      statusCode: 500,
      code: code,
      message: message,
    );
  }

  return ApiUnexpectedException(
    statusCode: 500,
    code: code,
    message: message,
  );
}

String postgrestCode(PostgrestException error) {
  final message = error.message;
  try {
    final decoded = jsonDecode(message);
    if (decoded is Map<String, dynamic>) {
      final code = decoded['code'] as String?;
      if (code != null && code.isNotEmpty) {
        return code;
      }
    }
  } on FormatException {
    // Supabase can also provide a plain-text PostgREST message.
  }

  return error.code ?? 'postgrest-error';
}

bool looksLikeNetworkFailure(Object error) {
  final description = error.toString().toLowerCase();
  return description.contains('socketexception') ||
      description.contains('clientexception') ||
      description.contains('failed host lookup') ||
      description.contains('connection refused') ||
      description.contains('connection closed') ||
      description.contains('network') ||
      description.contains('xmlhttprequest error') ||
      description.contains('timed out') ||
      description.contains('timeout');
}

void logSupabaseError({
  required String operation,
  required ApiException error,
}) {
  _logger.error(
    'supabase_request_error',
    message: 'Supabase request failed.',
    details: {
      'operation': operation,
      'status_code': error.statusCode,
      'error_code': error.code,
      'error_type': error.runtimeType.toString(),
      if (error.requestId != null) 'request_reference': 'available',
    },
  );
}

bool _isValidationPostgrestCode(String code) {
  return code == '23502' ||
      code == '23503' ||
      code == '23505' ||
      code == '23514' ||
      code == '22P02' ||
      code == '22001' ||
      code == 'PGRST102';
}
