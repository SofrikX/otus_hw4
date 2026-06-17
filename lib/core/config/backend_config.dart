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
    this.supabaseAnonKey = '',
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
      supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  final String baseUrl;
  final bool useFirebaseBackend;
  final bool useSupabaseBackend;
  final String supabaseUrl;
  final String supabaseAnonKey;

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

  String get requiredSupabaseAnonKey {
    final trimmedKey = supabaseAnonKey.trim();
    if (trimmedKey.isEmpty) {
      throw const BackendConfigException(
        'SUPABASE_ANON_KEY is required when USE_SUPABASE_BACKEND=true.',
      );
    }

    return trimmedKey;
  }
}

class BackendConfigException implements Exception {
  const BackendConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
