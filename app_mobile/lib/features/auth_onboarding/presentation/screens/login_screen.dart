import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/auth_error_banner.dart';

/// Real Login screen — Google, Apple (iOS/macOS only; `sign_in_with_apple`
/// needs `webAuthenticationOptions` to work on Android/web, which isn't
/// configured, so the button is hidden rather than shown broken), Email,
/// Guest Mode, Remember Me, and a biometric-retry affordance when the
/// session is merely [AuthLocked] rather than fully unauthenticated.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authViewModelProvider);
    final isBusy = authState is AuthAuthenticating;

    ref.listen(authViewModelProvider, (previous, next) {
      if (next is AuthAuthenticated) context.goNamed(AppRoute.home);
    });

    final showApplePlatformSupport = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Login', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              if (authState is AuthError) AuthErrorBanner(failure: authState.failure),
              if (authState is AuthLocked) ...[
                Text(
                  'Welcome back${authState.user.displayName != null ? ', ${authState.user.displayName}' : ''}.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => ref.read(authViewModelProvider.notifier).retryBiometric(),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Face ID / Touch ID'),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value ?? true),
                  ),
                  const Text('Remember me'),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: isBusy
                    ? null
                    : () => ref
                          .read(authViewModelProvider.notifier)
                          .signInWithEmail(
                            email: _emailController.text,
                            password: _passwordController.text,
                            rememberMe: _rememberMe,
                          ),
                child: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.logIn),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isBusy ? null : () => context.pushNamed(AppRoute.register),
                child: Text(l10n.goToRegister),
              ),
              const SizedBox(height: 16),
              const _OrDivider(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: isBusy
                    ? null
                    : () => ref
                          .read(authViewModelProvider.notifier)
                          .signInWithGoogle(rememberMe: _rememberMe),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
              ),
              if (showApplePlatformSupport) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => ref
                            .read(authViewModelProvider.notifier)
                            .signInWithApple(rememberMe: _rememberMe),
                  icon: const Icon(Icons.apple),
                  label: const Text('Continue with Apple'),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: isBusy
                    ? null
                    : () => ref
                          .read(authViewModelProvider.notifier)
                          .continueAsGuest(rememberMe: _rememberMe),
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or')),
        Expanded(child: Divider()),
      ],
    );
  }
}
