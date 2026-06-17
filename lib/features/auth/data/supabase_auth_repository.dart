import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_error.dart';
import '../../../core/supabase/supabase_error_mapper.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AppUser? get currentUser => _mapSupabaseUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map(
      (state) => _mapSupabaseUser(state.session?.user),
    );
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapRequiredUser(response.user);
      await _upsertProfile(user);
      return user;
    } on AuthException catch (error) {
      throw _authFailureFrom(error, operation: 'auth.signIn');
    } on PostgrestException catch (error) {
      throw _profileFailureFrom(error, operation: 'auth.upsertProfile');
    } on AuthFailure {
      rethrow;
    } on Object catch (error) {
      throw _unknownFailureFrom(error, operation: 'auth.signIn');
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final trimmedDisplayName = displayName?.trim();
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty)
            'display_name': trimmedDisplayName,
        },
      );

      final user = _mapRequiredUser(response.user);
      final mappedUser = user.copyWith(displayName: trimmedDisplayName);
      await _upsertProfile(mappedUser);
      return mappedUser;
    } on AuthException catch (error) {
      throw _authFailureFrom(error, operation: 'auth.register');
    } on PostgrestException catch (error) {
      throw _profileFailureFrom(error, operation: 'auth.upsertProfile');
    } on AuthFailure {
      rethrow;
    } on Object catch (error) {
      throw _unknownFailureFrom(error, operation: 'auth.register');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      final mapped = mapSupabaseAuthException(error);
      logSupabaseError(operation: 'auth.signOut', error: mapped);
      throw AuthFailure(mapped.userMessage);
    } on Object catch (error) {
      throw _unknownFailureFrom(error, operation: 'auth.signOut');
    }
  }

  AppUser _mapRequiredUser(User? user) {
    final mappedUser = _mapSupabaseUser(user);
    if (mappedUser == null) {
      throw const AuthFailure('Не удалось получить пользователя.');
    }

    return mappedUser;
  }

  AppUser? _mapSupabaseUser(User? user) {
    if (user == null) {
      return null;
    }

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName = metadata['display_name'] as String? ??
        metadata['name'] as String? ??
        metadata['full_name'] as String?;

    return AppUser(
      id: user.id,
      email: user.email,
      displayName: displayName,
    );
  }

  Future<void> _upsertProfile(AppUser user) async {
    await _client.from('profiles').upsert({
      'id': user.id,
      'display_name': user.displayName?.trim().isNotEmpty ?? false
          ? user.displayName!.trim()
          : user.email ?? 'PetConnect user',
      'email': user.email,
    });
  }

  AuthFailure _authFailureFrom(
    AuthException error, {
    required String operation,
  }) {
    final mapped = mapSupabaseAuthException(error);
    logSupabaseError(operation: operation, error: mapped);

    final code = error.code ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return const AuthFailure('Email или пароль не подошли.');
    }
    if (code == 'email_exists' ||
        message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('user already registered')) {
      return const AuthFailure('Пользователь с таким email уже есть.');
    }
    if (code == 'weak_password' || message.contains('password')) {
      return const AuthFailure('Пароль должен быть надежнее.');
    }
    if (code == 'validation_failed' || message.contains('email')) {
      return const AuthFailure('Проверьте формат email.');
    }
    if (mapped is ApiNetworkException) {
      return const AuthFailure('Нет соединения с сервисом авторизации.');
    }

    return AuthFailure(mapped.userMessage);
  }

  AuthFailure _profileFailureFrom(
    PostgrestException error, {
    required String operation,
  }) {
    final mapped = mapSupabasePostgrestException(error);
    logSupabaseError(operation: operation, error: mapped);

    if (mapped is ApiForbiddenException) {
      return const AuthFailure(
        'Аккаунт создан, но профиль не удалось сохранить из-за прав доступа.',
      );
    }

    return const AuthFailure(
        'Аккаунт создан, но профиль не удалось сохранить.');
  }

  AuthFailure _unknownFailureFrom(
    Object error, {
    required String operation,
  }) {
    if (error is Error) {
      throw error;
    }

    final mapped = looksLikeNetworkFailure(error)
        ? const ApiNetworkException()
        : ApiUnexpectedException(
            statusCode: 500,
            code: 'unknown-error',
            message: error.runtimeType.toString(),
          );
    logSupabaseError(operation: operation, error: mapped);

    if (mapped is ApiNetworkException) {
      return const AuthFailure('Нет соединения с сервисом авторизации.');
    }

    return AuthFailure(mapped.userMessage);
  }
}

extension on AppUser {
  AppUser copyWith({
    String? displayName,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
    );
  }
}
