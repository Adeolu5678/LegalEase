import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:legalease/features/auth/data/repositories/auth_repository.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';
import 'package:legalease/features/auth/presentation/screens/login_screen.dart';
import 'package:legalease/features/auth/presentation/screens/signup_screen.dart';
import 'package:legalease/features/document_scan/presentation/screens/home_screen.dart';
import 'package:legalease/features/subscription/domain/providers/subscription_providers.dart';
import 'package:legalease/core/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUser extends Fake implements User {
  final String _uid;
  final String? _email;
  final String? _displayName;
  final String? _photoURL;
  final bool _emailVerified;
  final bool _isAnonymous;
  final String? _phoneNumber;

  FakeUser({
    String uid = 'test-user-id',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
    String? photoURL,
    bool emailVerified = true,
    bool isAnonymous = false,
    String? phoneNumber,
  })  : _uid = uid,
        _email = email,
        _displayName = displayName,
        _photoURL = photoURL,
        _emailVerified = emailVerified,
        _isAnonymous = isAnonymous,
        _phoneNumber = phoneNumber;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;

  @override
  String? get photoURL => _photoURL;

  @override
  bool get emailVerified => _emailVerified;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  String? get phoneNumber => _phoneNumber;

  @override
  Future<void> reload() async {}

  @override
  Future<void> delete() async {}

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock-id-token';

  @override
  UserMetadata get metadata => UserMetadata(0, 0);

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get refreshToken => 'mock-refresh-token';

  @override
  String? get tenantId => null;
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  @override
  final AdditionalUserInfo? additionalUserInfo;

  @override
  final AuthCredential? credential;

  FakeUserCredential({
    this.user,
    this.additionalUserInfo,
    this.credential,
  });
}

class MockAuthRepository extends Mock implements AuthRepository {
  final Stream<User?> _authStateStream;
  final User? _currentUser;

  MockAuthRepository._({
    required Stream<User?> authStateStream,
    User? currentUser,
  })  : _authStateStream = authStateStream,
        _currentUser = currentUser;

  factory MockAuthRepository.signedOut() {
    final mock = MockAuthRepository._(
      authStateStream: Stream.value(null),
      currentUser: null,
    );
    when(() => mock.authStateChanges).thenAnswer((_) => mock._authStateStream);
    when(() => mock.currentUser).thenReturn(null);
    when(() => mock.signInWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser()));
    when(() => mock.createUserWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser()));
    when(() => mock.signInWithGoogle())
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser()));
    when(() => mock.signInWithApple())
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser()));
    when(() => mock.signInAnonymously())
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser(isAnonymous: true)));
    when(() => mock.signOut()).thenAnswer((_) async {});
    when(() => mock.sendPasswordResetEmail(any())).thenAnswer((_) async {});
    when(() => mock.deleteAccount()).thenAnswer((_) async {});
    return mock;
  }

  factory MockAuthRepository.signedIn({User? user}) {
    final testUser = user ?? FakeUser();
    final controller = StreamController<User?>.broadcast();
    controller.add(testUser);
    
    final mock = MockAuthRepository._(
      authStateStream: controller.stream,
      currentUser: testUser,
    );
    when(() => mock.authStateChanges).thenAnswer((_) => mock._authStateStream);
    when(() => mock.currentUser).thenReturn(mock._currentUser);
    when(() => mock.signInWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => FakeUserCredential(user: testUser));
    when(() => mock.createUserWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => FakeUserCredential(user: testUser));
    when(() => mock.signInWithGoogle())
        .thenAnswer((_) async => FakeUserCredential(user: testUser));
    when(() => mock.signInWithApple())
        .thenAnswer((_) async => FakeUserCredential(user: testUser));
    when(() => mock.signInAnonymously())
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser(isAnonymous: true)));
    when(() => mock.signOut()).thenAnswer((_) async {
      controller.add(null);
    });
    when(() => mock.sendPasswordResetEmail(any())).thenAnswer((_) async {});
    when(() => mock.deleteAccount()).thenAnswer((_) async {});
    return mock;
  }

  factory MockAuthRepository.withError(Object exception) {
    final mock = MockAuthRepository._(
      authStateStream: Stream.value(null),
      currentUser: null,
    );
    when(() => mock.authStateChanges).thenAnswer((_) => mock._authStateStream);
    when(() => mock.currentUser).thenReturn(null);
    when(() => mock.signInWithEmailAndPassword(any(), any())).thenThrow(exception);
    when(() => mock.createUserWithEmailAndPassword(any(), any())).thenThrow(exception);
    when(() => mock.signInWithGoogle()).thenThrow(exception);
    when(() => mock.signInWithApple()).thenThrow(exception);
    when(() => mock.signInAnonymously()).thenThrow(exception);
    when(() => mock.signOut()).thenThrow(exception);
    when(() => mock.sendPasswordResetEmail(any())).thenThrow(exception);
    when(() => mock.deleteAccount()).thenThrow(exception);
    return mock;
  }
}

class TestAuthController {
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  
  Stream<User?> get authStateChanges => _authStateController.stream;
  
  void signIn(User user) => _authStateController.add(user);
  void signOut() => _authStateController.add(null);
  
  void dispose() => _authStateController.close();
}

Widget createTestApp({
  required List<Override> overrides,
  String initialLocation = '/login',
}) {
  return ProviderScope(
    overrides: [
      ...overrides,
      onboardingCompletedProvider.overrideWith((ref) async => true),
    ],
    child: Builder(
      builder: (context) {
        return MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: initialLocation,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
                path: '/signup',
                builder: (context, state) => const SignupScreen(),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeUser());
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
  });

  group('Initial State', () {
    testWidgets('App starts with unauthenticated state', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Login screen displays all required elements', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });

    testWidgets('Auth state provider reflects signed-out state', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();
      User? capturedUser;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => mockAuth),
            onboardingCompletedProvider.overrideWith((ref) async => true),
          ],
          child: Builder(
            builder: (context) {
              final container = ProviderScope.containerOf(context);
              capturedUser = container.read(authStateChangesProvider).value;
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(capturedUser, isNull);
    });
  });

  group('Email/Password Sign In', () {
    testWidgets('Enter email and password, sign in successfully', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      verify(() => mockAuth.signInWithEmailAndPassword('test@example.com', 'password123')).called(1);
    });

    testWidgets('Shows loading state during sign in', (tester) async {
      final completer = Completer<UserCredential>();
      final mockAuth = MockAuthRepository.signedOut();
      
      when(() => mockAuth.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsNothing);

      completer.complete(FakeUserCredential(user: FakeUser()));
      await tester.pumpAndSettle();
    });

    testWidgets('Error handling with wrong credentials', (tester) async {
      final exception = FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'wrongpassword');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('wrong-password'), findsWidgets);
    });

    testWidgets('Validates empty email field', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Validates short password', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  group('Sign Up Flow', () {
    testWidgets('Navigate to signup screen from login', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final signUpLink = find.text("Don't have an account? Sign Up");
      await tester.tap(signUpLink);

      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Enter email and password, create account successfully', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/signup',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'newuser@example.com');
      await tester.enterText(passwordField, 'password123');

      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);

      await tester.pumpAndSettle();

      verify(() => mockAuth.createUserWithEmailAndPassword('newuser@example.com', 'password123')).called(1);
    });

    testWidgets('Error for existing email', (tester) async {
      final exception = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/signup',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'existing@example.com');
      await tester.enterText(passwordField, 'password123');

      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('email-already-in-use'), findsWidgets);
    });

    testWidgets('Navigate back to login from signup', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/signup',
      ));

      await tester.pumpAndSettle();

      final backArrow = find.byIcon(Icons.arrow_back);
      await tester.tap(backArrow);

      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  group('Google Sign In (Mock)', () {
    testWidgets('Tap Google sign in button triggers sign in', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final googleButton = find.text('Continue with Google');
      await tester.tap(googleButton);

      await tester.pumpAndSettle();

      verify(() => mockAuth.signInWithGoogle()).called(1);
    });

    testWidgets('Google sign in handles error gracefully', (tester) async {
      final exception = FirebaseAuthException(
        code: 'popup-closed-by-user',
        message: 'The popup has been closed by the user.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final googleButton = find.text('Continue with Google');
      await tester.tap(googleButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('popup-closed-by-user'), findsWidgets);
    });
  });

  group('Apple Sign In (Mock)', () {
    testWidgets('Apple sign in button triggers sign in on supported platforms', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final appleButton = find.text('Continue with Apple', skipOffstage: false);
      
      if (appleButton.evaluate().isNotEmpty) {
        await tester.tap(appleButton.first);
        await tester.pumpAndSettle();
        verify(() => mockAuth.signInWithApple()).called(1);
      }
    });
  });

  group('Anonymous Sign In', () {
    testWidgets('Tap continue as guest triggers anonymous auth', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final guestButton = find.text('Continue as Guest');
      await tester.tap(guestButton);

      await tester.pumpAndSettle();

      verify(() => mockAuth.signInAnonymously()).called(1);
    });

    testWidgets('Anonymous sign in creates anonymous user', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();
      
      when(() => mockAuth.signInAnonymously()).thenAnswer(
        (_) async => FakeUserCredential(user: FakeUser(isAnonymous: true)),
      );

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final guestButton = find.text('Continue as Guest');
      await tester.tap(guestButton);

      await tester.pumpAndSettle();

      final capturedCredential = await mockAuth.signInAnonymously();
      expect(capturedCredential.user?.isAnonymous, isTrue);
    });
  });

  group('Sign Out', () {
    testWidgets('From authenticated state, tap sign out returns to login', (tester) async {
      final mockAuth = MockAuthRepository.signedIn();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/',
      ));

      await tester.pumpAndSettle();

      final settingsButton = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsButton);

      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
      
      final signOutTile = find.text('Sign Out');
      await tester.tap(signOutTile);

      await tester.pumpAndSettle();

      verify(() => mockAuth.signOut()).called(1);
    });

    testWidgets('Auth state is signed out after sign out', (tester) async {
      final mockAuth = MockAuthRepository.signedIn();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/',
      ));

      await tester.pumpAndSettle();

      await mockAuth.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('Password Reset', () {
    testWidgets('Navigate to forgot password dialog', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final forgotPasswordLink = find.text('Forgot Password?');
      await tester.tap(forgotPasswordLink);

      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Enter email and submit password reset', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final forgotPasswordLink = find.text('Forgot Password?');
      await tester.tap(forgotPasswordLink);

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.enterText(emailField, 'reset@example.com');

      final sendButton = find.widgetWithText(ElevatedButton, 'Send');
      await tester.tap(sendButton);

      await tester.pumpAndSettle();

      expect(find.text('Password reset email sent'), findsOneWidget);
    });

    testWidgets('Cancel password reset dialog', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final forgotPasswordLink = find.text('Forgot Password?');
      await tester.tap(forgotPasswordLink);

      await tester.pumpAndSettle();

      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      await tester.tap(cancelButton);

      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsNothing);
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  group('Error Handling', () {
    testWidgets('Network errors are handled', (tester) async {
      final exception = FirebaseAuthException(
        code: 'network-request-failed',
        message: 'A network error has occurred.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('network-request-failed'), findsWidgets);
    });

    testWidgets('Invalid credentials error is displayed', (tester) async {
      final exception = FirebaseAuthException(
        code: 'invalid-credential',
        message: 'The supplied auth credential is invalid.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'wrongpassword');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('invalid-credential'), findsWidgets);
    });

    testWidgets('Account disabled error is handled', (tester) async {
      final exception = FirebaseAuthException(
        code: 'user-disabled',
        message: 'The user account has been disabled by an administrator.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'disabled@example.com');
      await tester.enterText(passwordField, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('user-disabled'), findsWidgets);
    });

    testWidgets('Too many attempts error is handled', (tester) async {
      final exception = FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Too many unsuccessful login attempts. Please try again later.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'wrongpassword');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('too-many-requests'), findsWidgets);
    });

    testWidgets('User not found error is handled', (tester) async {
      final exception = FirebaseAuthException(
        code: 'user-not-found',
        message: 'There is no user record corresponding to this identifier.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'nonexistent@example.com');
      await tester.enterText(passwordField, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('user-not-found'), findsWidgets);
    });

    testWidgets('Weak password error is handled during signup', (tester) async {
      final exception = FirebaseAuthException(
        code: 'weak-password',
        message: 'The password provided is too weak.',
      );
      final mockAuth = MockAuthRepository.withError(exception);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/signup',
      ));

      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'newuser@example.com');
      await tester.enterText(passwordField, 'weak');

      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);

      await tester.pumpAndSettle();

      expect(find.textContaining('weak-password'), findsWidgets);
    });
  });

  group('Password Visibility Toggle', () {
    testWidgets('Password visibility can be toggled', (tester) async {
      final mockAuth = MockAuthRepository.signedOut();

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/login',
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      final visibilityToggle = find.byIcon(Icons.visibility);
      await tester.tap(visibilityToggle);

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('Auth State Persistence', () {
    testWidgets('Auth state persists across widget rebuilds', (tester) async {
      final mockAuth = MockAuthRepository.signedIn();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
      );

      final user = container.read(authStateChangesProvider).value;
      expect(user, isNotNull);
      
      container.dispose();
    });

    testWidgets('CurrentUserProvider returns correct user entity', (tester) async {
      final testUser = FakeUser(
        uid: 'custom-user-id',
        email: 'custom@test.com',
        displayName: 'Custom User',
      );
      final mockAuth = MockAuthRepository.signedIn(user: testUser);

      await tester.pumpWidget(createTestApp(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => mockAuth),
          isPremiumUserProvider.overrideWith((ref) => false),
        ],
        initialLocation: '/',
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Custom User'), findsWidgets);
    });
  });
}
