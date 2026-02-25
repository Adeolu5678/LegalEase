import 'dart:io';

import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  final Future<void> Function() onGoogleSignIn;
  final Future<void> Function()? onAppleSignIn;
  final Future<void> Function()? onAnonymousSignIn;
  final bool isLoading;

  const SocialAuthButtons({
    super.key,
    required this.onGoogleSignIn,
    this.onAppleSignIn,
    this.onAnonymousSignIn,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),
        _SocialButton(
          text: 'Continue with Google',
          iconAsset: 'G',
          onPressed: isLoading ? null : onGoogleSignIn,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          borderColor: Colors.grey[300],
        ),
        if (Platform.isIOS || Platform.isMacOS) ...[
          const SizedBox(height: 12),
          _SocialButton(
            text: 'Continue with Apple',
            icon: Icons.apple,
            onPressed: isLoading ? null : onAppleSignIn,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ],
        if (onAnonymousSignIn != null) ...[
          const SizedBox(height: 12),
          _SocialButton(
            text: 'Continue as Guest',
            icon: Icons.person_outline,
            onPressed: isLoading ? null : onAnonymousSignIn,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? iconAsset;
  final Future<void> Function()? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _SocialButton({
    required this.text,
    this.icon,
    this.iconAsset,
    this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    iconAsset!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              )
            else
              Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
