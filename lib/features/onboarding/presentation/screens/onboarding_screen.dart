import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.document_scanner_rounded,
      title: 'Understand Legal Documents',
      description: 'Instantly translate complex legal jargon into plain English you can understand.',
      gradient: LinearGradient(
        colors: [AppColors.primary, Color(0xFF2B4C7E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPageData(
      icon: Icons.shield_rounded,
      title: 'Detect Hidden Risks',
      description: 'Our AI identifies red flags and potential issues in terms before you sign.',
      gradient: LinearGradient(
        colors: [AppColors.warning, AppColors.warningDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPageData(
      icon: Icons.chat_rounded,
      title: 'Chat with Your Documents',
      description: 'Ask questions and get instant answers from any document you upload.',
      gradient: LinearGradient(
        colors: [AppColors.success, AppColors.successDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPageData(
      icon: Icons.security_rounded,
      title: 'Stay Protected Everywhere',
      description: 'Real-time scanning of T&Cs on any app or website keeps you informed.',
      gradient: LinearGradient(
        colors: [AppColors.info, AppColors.infoDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/');
    }
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _PageIndicator(
                    pageCount: _pages.length,
                    currentPage: _currentPage,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: data.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (data.gradient.colors.first).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 64,
              color: Colors.white,
            ),
          ).animate().scale(
                duration: AppAnimation.medium,
                curve: AppAnimation.easeOutCubic,
              ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _PageIndicator({
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: AppBorderRadius.fullAll,
          ),
        );
      }),
    );
  }
}

Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') != true;
}
