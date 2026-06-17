import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petconnect/core/config/backend_config.dart';
import 'package:petconnect/core/data/mock_data.dart';
import 'package:petconnect/core/network/api_client.dart';
import 'package:petconnect/core/network/auth_token_provider.dart';
import 'package:petconnect/core/supabase/supabase_client_provider.dart';
import 'package:petconnect/features/walks/application/walks_controller.dart';
import 'package:petconnect/features/walks/data/api_walks_repository.dart';
import 'package:petconnect/features/walks/data/mock_walks_repository.dart';
import 'package:petconnect/features/walks/data/supabase_walk_repository.dart';
import 'package:petconnect/features/walks/domain/walk.dart';
import 'package:petconnect/features/walks/domain/walks_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    expect(joined, WalkJoinStatus.joined);
    final updatedWalk = controller.state.value?.first;
    expect(updatedWalk?.isJoined, isTrue);
    expect(updatedWalk?.participantCount, 4);
  });

  test('joinWalk reports already joined without error state', () async {
    final walk = mockWalks.first.copyWith(isJoined: false, participantCount: 3);
    final controller = WalksController(
      repository: _FakeWalksRepository(
        walks: [walk],
        joinResult: const WalkJoinResult(
          walkId: 'walk-1',
          isJoined: true,
          participantsCount: 3,
          alreadyJoined: true,
        ),
      ),
      initialState: AsyncValue<List<Walk>>.data([walk]),
    );

    final joined = await controller.joinWalk(walk.id);

    expect(joined, WalkJoinStatus.alreadyJoined);
    expect(controller.state.hasError, isFalse);
    expect(controller.state.value?.first.isJoined, isTrue);
    expect(controller.state.value?.first.participantCount, 3);
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

    expect(joined, WalkJoinStatus.failed);
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

  test('walksRepositoryProvider uses Supabase repository in backend mode', () {
    final container = ProviderContainer(
      overrides: [
        backendConfigProvider.overrideWithValue(
          const BackendConfig(
            baseUrl: '',
            useSupabaseBackend: true,
            supabaseUrl: 'https://example.supabase.co',
            supabaseAnonKey: 'anon-key',
          ),
        ),
        supabaseClientProvider.overrideWithValue(
          SupabaseClient(
            'https://example.supabase.co',
            'anon-key',
            httpClient: MockClient((_) async => http.Response('[]', 200)),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(walksRepositoryProvider),
      isA<SupabaseWalkRepository>(),
    );
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
  Future<Walk> createWalk(CreateWalkInput input) async {
    return Walk(
      id: 'walk-new',
      title: input.title,
      place: input.place,
      startsAt: input.startsAt,
      description: input.description,
      organizerName: input.organizerName ?? 'Ava',
      participantCount: 0,
      isJoined: false,
    );
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

  @override
  Future<WalkJoinResult> leaveWalk(String walkId) async {
    final walk = walks.firstWhere((walk) => walk.id == walkId);
    return WalkJoinResult(
      walkId: walk.id,
      isJoined: false,
      participantsCount: walk.participantCount > 0
          ? walk.participantCount - 1
          : walk.participantCount,
    );
  }
}

class _FakeAuthTokenProvider implements AuthTokenProvider {
  const _FakeAuthTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}
