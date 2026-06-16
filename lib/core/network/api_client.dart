import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/backend_config.dart';
import 'api_error.dart';
import 'auth_token_provider.dart';

final backendConfigProvider = Provider<BackendConfig>((ref) {
  return BackendConfig.fromEnvironment();
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(backendConfigProvider);

  return ApiClient(
    baseUri: config.baseUri,
    httpClient: ref.watch(httpClientProvider),
    authTokenProvider: ref.watch(authTokenProvider),
  );
});

class ApiClient {
  const ApiClient({
    required Uri baseUri,
    required http.Client httpClient,
    required AuthTokenProvider authTokenProvider,
  })  : _baseUri = baseUri,
        _httpClient = httpClient,
        _authTokenProvider = authTokenProvider;

  final Uri _baseUri;
  final http.Client _httpClient;
  final AuthTokenProvider _authTokenProvider;

  Future<T> getData<T>(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<T> postData<T>(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _send<T>(
      method: 'POST',
      path: path,
      body: body,
    );
  }

  Future<List<Map<String, dynamic>>> getPosts({int? limit}) async {
    final data = await getData<List<dynamic>>(
      '/posts',
      queryParameters: _limitQuery(limit),
    );

    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createPost(Map<String, Object?> input) {
    return postData<Map<String, dynamic>>('/posts', body: input);
  }

  Future<Map<String, dynamic>> togglePostLike(String postId) {
    return postData<Map<String, dynamic>>('/posts/$postId/like');
  }

  Future<List<Map<String, dynamic>>> getWalks({int? limit}) async {
    final data = await getData<List<dynamic>>(
      '/walks',
      queryParameters: _limitQuery(limit),
    );

    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> joinWalk(String walkId) {
    return postData<Map<String, dynamic>>('/walks/$walkId/join');
  }

  Future<T> _send<T>({
    required String method,
    required String path,
    Map<String, String>? queryParameters,
    Map<String, Object?>? body,
  }) async {
    final request = http.Request(method, _resolve(path, queryParameters));
    request.headers.addAll(await _headers());

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      final streamedResponse = await _httpClient.send(request);
      response = await http.Response.fromStream(streamedResponse);
    } on http.ClientException {
      throw const ApiNetworkException();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedBody = _decodeBody(response.body);
      final data = decodedBody['data'];
      return data as T;
    }

    throw _exceptionFromResponse(response);
  }

  Uri _resolve(String path, Map<String, String>? queryParameters) {
    final normalizedBasePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return _baseUri.replace(
      path: '$normalizedBasePath$normalizedPath',
      queryParameters:
          queryParameters?.isEmpty ?? true ? null : queryParameters,
    );
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = await _authTokenProvider.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const ApiUnexpectedException(
      statusCode: 500,
      code: 'invalid-response',
      message: 'Backend returned an unexpected response.',
    );
  }

  ApiException _exceptionFromResponse(http.Response response) {
    final error = _readError(response);
    final message = error.message;

    switch (response.statusCode) {
      case 400:
        return ApiValidationException(message: message, code: error.code);
      case 401:
        return ApiUnauthorizedException(message: message, code: error.code);
      case 403:
        return ApiForbiddenException(message: message, code: error.code);
      case 404:
        return ApiNotFoundException(message: message, code: error.code);
      case >= 500:
        return ApiServerException(
          message: message,
          statusCode: response.statusCode,
          code: error.code,
        );
      default:
        return ApiUnexpectedException(
          statusCode: response.statusCode,
          code: error.code,
          message: message,
        );
    }
  }

  _ApiErrorPayload _readError(http.Response response) {
    try {
      final decodedBody = _decodeBody(response.body);
      final error = decodedBody['error'];
      if (error is Map<String, dynamic>) {
        return _ApiErrorPayload(
          code: error['code'] as String? ?? 'unknown-error',
          message: error['message'] as String? ?? 'Request failed.',
        );
      }
    } on FormatException {
      // Fall through to a generic typed exception.
    } on ApiException {
      // Fall through to a generic typed exception.
    }

    return _ApiErrorPayload(
      code: 'http-${response.statusCode}',
      message: 'Request failed with status ${response.statusCode}.',
    );
  }

  Map<String, String>? _limitQuery(int? limit) {
    if (limit == null) {
      return null;
    }

    return {'limit': '$limit'};
  }
}

class _ApiErrorPayload {
  const _ApiErrorPayload({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}
