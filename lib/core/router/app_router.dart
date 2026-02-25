import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/auth/presentation/screens/login_screen.dart';
import 'package:legalease/features/auth/presentation/screens/signup_screen.dart';
import 'package:legalease/features/document_scan/presentation/screens/document_upload_screen.dart';
import 'package:legalease/features/document_scan/presentation/screens/analysis_processing_screen.dart';
import 'package:legalease/features/document_scan/presentation/screens/analysis_result_screen.dart';
import 'package:legalease/features/document_scan/presentation/screens/home_screen.dart';
import 'package:legalease/features/chat/presentation/screens/chat_screen.dart';
import 'package:legalease/features/settings/presentation/screens/persona_settings_screen.dart';
import 'package:legalease/features/settings/presentation/screens/persona_create_screen.dart';
import 'package:legalease/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:legalease/features/subscription/presentation/screens/subscription_management_screen.dart';
import 'package:legalease/features/writing_assistant/presentation/screens/writing_assistant_overlay_screen.dart';
import 'package:legalease/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:legalease/features/export/presentation/screens/export_to_counsel_screen.dart';
import 'package:legalease/features/legal_dictionary/presentation/screens/dictionary_screen.dart';
import 'package:legalease/features/search/presentation/screens/search_screen.dart';
import 'package:legalease/features/comparison/presentation/screens/comparison_screen.dart';
import 'package:legalease/features/templates/presentation/screens/templates_screen.dart';
import 'package:legalease/features/templates/presentation/screens/template_preview_screen.dart';
import 'package:legalease/features/sharing/presentation/screens/share_analysis_screen.dart';
import 'package:legalease/features/cloud_storage/presentation/screens/cloud_accounts_screen.dart';
import 'package:legalease/features/templates/data/models/legal_template.dart';
import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/core/router/transitions/fade_page_route.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const DocumentUploadScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.right,
          child: const DocumentUploadScreen(),
        ),
      ),
      GoRoute(
        path: '/analysis/processing',
        builder: (context, state) => const AnalysisProcessingScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const AnalysisProcessingScreen(),
        ),
      ),
      GoRoute(
        path: '/analysis/result',
        builder: (context, state) => const AnalysisResultScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.left,
          child: const AnalysisResultScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.left,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return ChatScreen(
              documentId: extra['documentId'] as String?,
              documentTitle: extra['documentTitle'] as String?,
            );
          }
          return const ChatScreen();
        },
        pageBuilder: (context, state) {
          final extra = state.extra;
          Widget child;
          if (extra is Map<String, dynamic>) {
            child = ChatScreen(
              documentId: extra['documentId'] as String?,
              documentTitle: extra['documentTitle'] as String?,
            );
          } else {
            child = const ChatScreen();
          }
          return buildSlideTransitionPage(
            state: state,
            direction: AxisDirection.up,
            child: child,
          );
        },
      ),
      GoRoute(
        path: '/settings/personas',
        builder: (context, state) => const PersonaSettingsScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const PersonaSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/personas/create',
        builder: (context, state) => const PersonaCreateScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.left,
          child: const PersonaCreateScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/personas/edit',
        builder: (context, state) {
          final persona = state.extra as Persona?;
          return PersonaCreateScreen(persona: persona);
        },
        pageBuilder: (context, state) {
          final persona = state.extra as Persona?;
          return buildSlideTransitionPage(
            state: state,
            direction: AxisDirection.left,
            child: PersonaCreateScreen(persona: persona),
          );
        },
      ),
      GoRoute(
        path: '/writing-assistant',
        builder: (context, state) => const WritingAssistantOverlayScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const WritingAssistantOverlayScreen(),
        ),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.up,
          child: const SubscriptionScreen(),
        ),
      ),
      GoRoute(
        path: '/subscription/manage',
        builder: (context, state) => const SubscriptionManagementScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const SubscriptionManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/export/counsel',
        builder: (context, state) {
          final result = state.extra as AnalysisResult?;
          if (result == null) {
            return const Scaffold(body: Center(child: Text('No analysis result provided')));
          }
          return ExportToCounselScreen(analysisResult: result);
        },
        pageBuilder: (context, state) {
          final result = state.extra as AnalysisResult?;
          return buildSlideTransitionPage(
            state: state,
            direction: AxisDirection.left,
            child: result != null
                ? ExportToCounselScreen(analysisResult: result)
                : const Scaffold(body: Center(child: Text('No analysis result provided'))),
          );
        },
      ),
      GoRoute(
        path: '/dictionary',
        builder: (context, state) => const DictionaryScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.left,
          child: const DictionaryScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.left,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/comparison',
        builder: (context, state) => const ComparisonScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const ComparisonScreen(),
        ),
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TemplatesScreen(),
        pageBuilder: (context, state) => buildSlideTransitionPage(
          state: state,
          direction: AxisDirection.left,
          child: const TemplatesScreen(),
        ),
      ),
      GoRoute(
        path: '/templates/preview',
        builder: (context, state) {
          final template = state.extra as LegalTemplate?;
          if (template == null) {
            return const Scaffold(body: Center(child: Text('No template provided')));
          }
          return TemplatePreviewScreen(template: template);
        },
        pageBuilder: (context, state) {
          final template = state.extra as LegalTemplate?;
          return buildSlideTransitionPage(
            state: state,
            direction: AxisDirection.left,
            child: template != null
                ? TemplatePreviewScreen(template: template)
                : const Scaffold(body: Center(child: Text('No template provided'))),
          );
        },
      ),
      GoRoute(
        path: '/share',
        builder: (context, state) {
          final result = state.extra as AnalysisResult?;
          if (result == null) {
            return const Scaffold(body: Center(child: Text('No analysis result provided')));
          }
          return ShareAnalysisScreen(analysisResult: result);
        },
        pageBuilder: (context, state) {
          final result = state.extra as AnalysisResult?;
          return buildSlideTransitionPage(
            state: state,
            direction: AxisDirection.left,
            child: result != null
                ? ShareAnalysisScreen(analysisResult: result)
                : const Scaffold(body: Center(child: Text('No analysis result provided'))),
          );
        },
      ),
      GoRoute(
        path: '/cloud/accounts',
        builder: (context, state) => const CloudAccountsScreen(),
        pageBuilder: (context, state) => buildFadeTransitionPage(
          state: state,
          child: const CloudAccountsScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      final onboardingAsync = ref.read(onboardingCompletedProvider);
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      
      if (onboardingAsync.isLoading) {
        return null;
      }
      
      final onboardingCompleted = onboardingAsync.valueOrNull ?? false;
      
      if (!onboardingCompleted && !isOnboardingRoute) {
        return '/onboarding';
      }
      
      if (onboardingCompleted && isOnboardingRoute) {
        return '/';
      }
      
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.error?.toString() ?? 'The requested page does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
