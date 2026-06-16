import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/config/backend_config.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/core/network/api_client.dart';
import 'package:petconnect/core/network/auth_token_provider.dart';
import 'package:petconnect/features/walks/application/walks_controller.dart';
import 'package:petconnect/features/walks/data/api_walks_repository.dart';
import 'package:petconnect/features/walks/data/mock_walks_repository.dart';
import 'package:petconnect/features/walks/domain/walk.dart';
import 'package:petconnect/features/walks/domain/walks_repository.dart';

void main() {
  test('refresh loads walks from repository', () async {
    final controller = WalksController(
      repository: _FakeWalksRepository(walks: [mockWalks.first]),
      initialState: const AsyncValue<List<Walk>>.loading(),
    );

    await controller.refresh();

    expect(controller.state.hasValue, isTrue);
    expect(controller.state.value, [mockWalks.first]);
  });

  test('refresh exposes backend error state', () async {
    final controller = WalksController(
      repository: _FakeWalksRepository(fetchError: Exception('Backend down')),
      initialState: const AsyncValue<List<Walk>>.loading(),
    );

    await controller.refresh();

    expect(controller.state.hasError, isTrue);
    expect(controller.state.error.toString(), contains('Backend down'));
  });

  test('joinWalk updates walk state from repository result', () async {
    final walk = mockWalks.first.copyWith(isJoined: false, participantCount: 3);
    final controller = WalksController(
      repository: _FakeWalksRepository(
        walks: [walk],
        joinResult: const WalkJoinResult(
          walkId: 'walk-1',
          isJoined: true,
          participantsCount: 4,
        ),
      ),
      initialState: AsyncValue<List<Walk>>.data([walk]),
    );

    final joined = await controller.joinWalk(walk.id);

    expect(joined, isTrue);
    final updatedWalk = controller.state.value?.first;
    expect(updatedWalk?.isJoined, isTrue);
    expect(updatedWalk?.participantCount, 4);
  });

  test('joinWalk exposes backend error state', () async {
    final walk = mockWalks.first.copyWith(isJoined: false);
    final controller = WalksController(
      repository: _FakeWalksRepository(
        walks: [walk],
        joinError: Exception('Walk join failed'),
      ),
      initialState: AsyncValue<List<Walk>>.data([walk]),
    );

    final joined = await controller.joinWalk(walk.id);

    expect(joined, isFalse);
    expect(controller.state.hasError, isTrue);
    expect(controller.state.error.toString(), contains('Walk join failed'));
  });

  test('walksRepositoryProvider uses mock repository by default', () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(baseUrl: '', useFirebaseBackend: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(walksRepositoryProvider), isA<MockWalksRepository>());
  });

  test('walksRepositoryProvider uses API repository when backend is enabled',
      () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(
            baseUrl: 'http://127.0.0.1:5001/demo/us-central1/api',
            useFirebaseBackend: true,
          ),
        ),
        apiClientProvider.overrideWithValue(
          ApiClient(
            baseUri: Uri.parse('http://127.0.0.1:5001/demo/us-central1/api'),
            httpClient:
                MockClient((_) async => http.Response('{"data":[]}', 200)),
            authTokenProvider: const _FakeAuthTokenProvider('token-123'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(walksRepositoryProvider), isA<ApiWalksRepository>());
  });
}

class _FakeWalksRepository implements WalksRepository {
  const _FakeWalksRepository({
    this.walks = const [],
    this.joinResult,
    this.fetchError,
    this.joinError,
  });

  final List<Walk> walks;
  final WalkJoinResult? joinResult;
  final Object? fetchError;
  final Object? joinError;

  @override
  Future<List<Walk>> fetchWalks({int limit = 20}) async {
    final error = fetchError;
    if (error != null) {
      throw error;
    }

    return walks.take(limit).toList(growable: false);
  }

  @override
  Future<WalkJoinResult> joinWalk(String walkId) async {
    final error = joinError;
    if (error != null) {
      throw error;
    }

    final result = joinResult;
    if (result != null) {
      return result;
    }

    final walk = walks.firstWhere((walk) => walk.id == walkId);
    return WalkJoinResult(
      walkId: walk.id,
      isJoined: true,
      participantsCount: walk.participantCount + 1,
    );
  }
}

class _FakeAuthTokenProvider implements AuthTokenProvider {
  const _FakeAuthTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}
