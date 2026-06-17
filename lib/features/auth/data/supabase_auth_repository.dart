import 'package:supabase_flutter/supabase_flutter.dart';

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
      throw AuthFailure(_friendlySupabaseAuthMessage(error));
    } on PostgrestException catch (error) {
      throw AuthFailure(_friendlyProfileMessage(error));
    } on AuthFailure {
      rethrow;
    } on Object {
      throw const AuthFailure('Нет соединения с сервисом авторизации.');
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
      throw AuthFailure(_friendlySupabaseAuthMessage(error));
    } on PostgrestException catch (error) {
      throw AuthFailure(_friendlyProfileMessage(error));
    } on AuthFailure {
      rethrow;
    } on Object {
      throw const AuthFailure('Нет соединения с сервисом авторизации.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthFailure(_friendlySupabaseAuthMessage(error));
    } on Object {
      throw const AuthFailure('Не удалось выйти. Проверьте соединение.');
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

  String _friendlySupabaseAuthMessage(AuthException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'Email или пароль не подошли.';
    }
    if (code == 'email_exists' ||
        message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('user already registered')) {
      return 'Пользователь с таким email уже есть.';
    }
    if (code == 'weak_password' || message.contains('password')) {
      return 'Пароль должен быть надежнее.';
    }
    if (code == 'validation_failed' || message.contains('email')) {
      return 'Проверьте формат email.';
    }
    if (error.statusCode == null || message.contains('network')) {
      return 'Нет соединения с сервисом авторизации.';
    }

    return 'Не удалось выполнить вход. Попробуйте еще раз.';
  }

  String _friendlyProfileMessage(PostgrestException error) {
    if (error.code == '42501') {
      return 'Аккаунт создан, но профиль не удалось сохранить из-за прав доступа.';
    }

    return 'Аккаунт создан, но профиль не удалось сохранить.';
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
