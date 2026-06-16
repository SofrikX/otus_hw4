import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/network/api_client.dart';
import 'package:petconnect/core/network/api_error.dart';
import 'package:petconnect/core/network/auth_token_provider.dart';

void main() {
  test('successful GET returns data and sends bearer token', () async {
    http.Request? capturedRequest;
    final client = ApiClient(
      baseUri: Uri.parse('http://127.0.0.1:5001/demo/us-central1/api'),
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          '{"data":[{"id":"post-1","text":"Hello"}]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
      authTokenProvider: const _FakeAuthTokenProvider('token-123'),
    );

    final posts = await client.getPosts(limit: 10);

    expect(posts, hasLength(1));
    expect(posts.first['id'], 'post-1');
    expect(capturedRequest?.method, 'GET');
    expect(capturedRequest?.url.path, '/demo/us-central1/api/posts');
    expect(capturedRequest?.url.queryParameters['limit'], '10');
    expect(capturedRequest?.headers['Authorization'], 'Bearer token-123');
  });

  test('401 response throws ApiUnauthorizedException', () async {
    final client = ApiClient(
      baseUri: Uri.parse('http://127.0.0.1:5001/demo/us-central1/api'),
      httpClient: MockClient((_) async {
        return http.Response(
          '{"error":{"code":"unauthorized","message":"Firebase ID token is required."}}',
          401,
        );
      }),
      authTokenProvider: const _FakeAuthTokenProvider(null),
    );

    expect(
      () => client.getPosts(),
      throwsA(
        isA<ApiUnauthorizedException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.code, 'code', 'unauthorized')
            .having(
              (error) => error.message,
              'message',
              'Firebase ID token is required.',
            ),
      ),
    );
  });

  test('500 response throws ApiServerException', () async {
    final client = ApiClient(
      baseUri: Uri.parse('http://127.0.0.1:5001/demo/us-central1/api'),
      httpClient: MockClient((_) async {
        return http.Response(
          '{"error":{"code":"internal-error","message":"Unexpected backend error."}}',
          500,
        );
      }),
      authTokenProvider: const _FakeAuthTokenProvider('token-123'),
    );

    expect(
      () => client.getWalks(),
      throwsA(
        isA<ApiServerException>()
            .having((error) => error.statusCode, 'statusCode', 500)
            .having((error) => error.code, 'code', 'internal-error')
            .having(
              (error) => error.message,
              'message',
              'Unexpected backend error.',
            ),
      ),
    );
  });
}

class _FakeAuthTokenProvider implements AuthTokenProvider {
  const _FakeAuthTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}
