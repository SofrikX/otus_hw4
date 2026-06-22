import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import 'auth_landing_layout.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _PendingAuthAction? _pendingAction;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final isEmailLoading =
        isLoading && _pendingAction == _PendingAuthAction.email;
    final isGoogleLoading =
        isLoading && _pendingAction == _PendingAuthAction.google;

    return AuthLandingLayout(
      formTitle: 'Вход',
      formSubtitle: 'Откройте ленту, прогулки, питомцев и чаты.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (authState.hasError) ...[
            _AuthErrorBanner(error: authState.error),
            const SizedBox(height: 16),
          ],
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('login-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('login-password'),
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  keyValue: const Key('login-submit'),
                  onPressed: isLoading ? null : _submit,
                  icon: Icons.login,
                  isLoading: isEmailLoading,
                  label: 'Войти',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('login-google'),
                  onPressed: isLoading ? null : _signInWithGoogle,
                  icon: isGoogleLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata),
                  label: const Text('Войти через Google'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('go-register'),
                  onPressed: isLoading ? null : () => context.go('/register'),
                  child: const Text('Создать аккаунт'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Введите email';
    }
    if (!email.contains('@')) {
      return 'Проверьте email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Минимум 6 символов';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _pendingAction = _PendingAuthAction.email);
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (mounted) {
      setState(() => _pendingAction = null);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _pendingAction = _PendingAuthAction.google);
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (mounted) {
      setState(() => _pendingAction = null);
    }
  }
}

enum _PendingAuthAction { email, google }

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _friendlyMessage(error),
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyMessage(Object? error) {
    final message = error.toString().trim();
    if (message.isEmpty || message == 'null') {
      return 'Не удалось войти. Попробуйте еще раз.';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
