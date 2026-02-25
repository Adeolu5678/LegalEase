import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';
import 'package:legalease/features/auth/presentation/widgets/auth_form.dart';
import 'package:legalease/features/auth/presentation/widgets/social_auth_buttons.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _isLoading = false;

  Future<void> _handleEmailSignup(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).createUserWithEmailAndPassword(email, password);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAnonymousSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInAnonymously();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthForm(
                    title: 'Create Account',
                    buttonText: 'Sign Up',
                    onSubmit: _handleEmailSignup,
                    onToggleAuthMode: () => context.pop(),
                    toggleText: 'Already have an account? Sign In',
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
