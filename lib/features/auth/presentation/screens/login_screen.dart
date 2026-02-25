import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';
import 'package:legalease/features/auth/presentation/widgets/auth_form.dart';
import 'package:legalease/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:legalease/shared/widgets/toast_notification.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleEmailLogin(String email, String password) async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(email, password);
      if (mounted) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (mounted) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
      if (mounted) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAnonymousSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInAnonymously();
      if (mounted) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    ToastNotification.error(
      context,
      message: message,
      actionLabel: 'Dismiss',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gavel,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LegalEase',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-powered legal assistant',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 48),
                  AuthForm(
                    title: 'Welcome Back',
                    buttonText: 'Sign In',
                    onSubmit: _handleEmailLogin,
                    onToggleAuthMode: () => context.push('/signup'),
                    toggleText: "Don't have an account? Sign Up",
                    showForgotPassword: true,
                  ),
                  const SizedBox(height: 24),
                  SocialAuthButtons(
                    onGoogleSignIn: _handleGoogleSignIn,
                    onAppleSignIn: _handleAppleSignIn,
                    onAnonymousSignIn: _handleAnonymousSignIn,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
