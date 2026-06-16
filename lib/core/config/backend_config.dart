class BackendConfig {
  const BackendConfig({
    required this.baseUrl,
    required this.useFirebaseBackend,
  });

  factory BackendConfig.fromEnvironment() {
    return const BackendConfig(
      baseUrl: String.fromEnvironment('API_BASE_URL'),
      useFirebaseBackend: bool.fromEnvironment(
        'USE_FIREBASE_BACKEND',
      ),
    );
  }

  final String baseUrl;
  final bool useFirebaseBackend;

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
}

class BackendConfigException implements Exception {
  const BackendConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
