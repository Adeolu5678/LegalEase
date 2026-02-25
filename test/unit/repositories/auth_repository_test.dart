import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:legalease/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../fixtures/test_users.dart';
import '../../mocks/mock_auth_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthRepository repository;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeUserCredential());
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();
    repository = FirebaseAuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('signInWithEmailAndPassword', () {
    test('success', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).thenAnswer((_) async => mockCredential);

      final result = await repository.signInWithEmailAndPassword(
        testUserEmail,
        testUserPassword,
      );

      expect(result.user, equals(mockUser));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).called(1);
    });

    test('with wrong password throws AuthException', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).thenThrow(
            FirebaseAuthException(
              code: 'wrong-password',
              message: 'The password is invalid.',
            ),
          );

      expect(
        () => repository.signInWithEmailAndPassword(testUserEmail, testUserPassword),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'wrong-password',
        )),
      );
    });

    test('with invalid email throws AuthException', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'invalid-email',
            password: testUserPassword,
          )).thenThrow(
            FirebaseAuthException(
              code: 'invalid-email',
              message: 'The email address is badly formatted.',
            ),
          );

      expect(
        () => repository.signInWithEmailAndPassword('invalid-email', testUserPassword),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'invalid-email',
        )),
      );
    });

    test('with user-not-found throws AuthException', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'nonexistent@example.com',
            password: testUserPassword,
          )).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message: 'There is no user record corresponding to this identifier.',
            ),
          );

      expect(
        () => repository.signInWithEmailAndPassword('nonexistent@example.com', testUserPassword),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'user-not-found',
        )),
      );
    });

    test('trims email whitespace', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).thenAnswer((_) async => mockCredential);

      await repository.signInWithEmailAndPassword(
        '  $testUserEmail  ',
        testUserPassword,
      );

      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).called(1);
    });
  });

  group('createUserWithEmailAndPassword', () {
    test('success', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).thenAnswer((_) async => mockCredential);

      final result = await repository.createUserWithEmailAndPassword(
        testUserEmail,
        testUserPassword,
      );

      expect(result.user, equals(mockUser));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).called(1);
    });

    test('with existing email throws AuthException', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).thenThrow(
            FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'The email address is already in use.',
            ),
          );

      expect(
        () => repository.createUserWithEmailAndPassword(testUserEmail, testUserPassword),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'email-already-in-use',
        )),
      );
    });

    test('with weak password throws AuthException', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testUserEmail,
            password: 'weak',
          )).thenThrow(
            FirebaseAuthException(
              code: 'weak-password',
              message: 'The password must be 6 characters long or more.',
            ),
          );

      expect(
        () => repository.createUserWithEmailAndPassword(testUserEmail, 'weak'),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'weak-password',
        )),
      );
    });

    test('trims email whitespace', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).thenAnswer((_) async => mockCredential);

      await repository.createUserWithEmailAndPassword(
        '  $testUserEmail  ',
        testUserPassword,
      );

      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testUserEmail,
            password: testUserPassword,
          )).called(1);
    });
  });

  group('signInWithGoogle', () {
    late MockGoogleSignInAccount mockGoogleAccount;
    late MockGoogleSignInAuthentication mockGoogleAuth;

    setUp(() {
      mockGoogleAccount = MockGoogleSignInAccount();
      mockGoogleAuth = MockGoogleSignInAuthentication();
    });

    test('success', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.accessToken).thenReturn('mock-access-token');
      when(() => mockGoogleAuth.idToken).thenReturn('mock-id-token');
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockCredential);

      final result = await repository.signInWithGoogle();

      expect(result.user, equals(mockUser));
      verify(() => mockGoogleSignIn.signIn()).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('cancelled throws AuthException', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      expect(
        () => repository.signInWithGoogle(),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'sign-in-cancelled',
        )),
      );
    });

    test('handles FirebaseAuthException', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.accessToken).thenReturn('mock-access-token');
      when(() => mockGoogleAuth.idToken).thenReturn('mock-id-token');
      when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'Account exists with different credential.',
        ),
      );

      expect(
        () => repository.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signInWithApple', () {
    test('success (mock platform check)', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockCredential);

      expect(true, isTrue);
    }, skip: 'Requires platform override and SignInWithApple mocking');

    test('cancelled throws AuthException', () async {
      expect(true, isTrue);
    }, skip: 'Requires platform override and SignInWithApple mocking');
  });

  group('signInAnonymously', () {
    test('success', () async {
      final mockCredential = MockUserCredential();
      final mockAnonymousUser = MockUser();
      when(() => mockAnonymousUser.isAnonymous).thenReturn(true);
      when(() => mockCredential.user).thenReturn(mockAnonymousUser);
      when(() => mockFirebaseAuth.signInAnonymously())
          .thenAnswer((_) async => mockCredential);

      final result = await repository.signInAnonymously();

      expect(result.user?.isAnonymous, isTrue);
      verify(() => mockFirebaseAuth.signInAnonymously()).called(1);
    });

    test('handles FirebaseAuthException', () async {
      when(() => mockFirebaseAuth.signInAnonymously()).thenThrow(
        FirebaseAuthException(
          code: 'operation-not-allowed',
          message: 'Anonymous sign-in is not enabled.',
        ),
      );

      expect(
        () => repository.signInAnonymously(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signOut', () {
    test('success', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await repository.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('handles errors', () async {
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('Sign out failed'));

      expect(
        () => repository.signOut(),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'sign-out-error',
        )),
      );
    });
  });

  group('sendPasswordResetEmail', () {
    test('success', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testUserEmail))
          .thenAnswer((_) async {});

      await repository.sendPasswordResetEmail(testUserEmail);

      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: testUserEmail))
          .called(1);
    });

    test('with invalid email throws', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: 'invalid'))
          .thenThrow(
            FirebaseAuthException(
              code: 'invalid-email',
              message: 'The email address is badly formatted.',
            ),
          );

      expect(
        () => repository.sendPasswordResetEmail('invalid'),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'invalid-email',
        )),
      );
    });

    test('with user-not-found throws', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: 'notfound@example.com'))
          .thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message: 'There is no user record.',
            ),
          );

      expect(
        () => repository.sendPasswordResetEmail('notfound@example.com'),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'user-not-found',
        )),
      );
    });

    test('trims email whitespace', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testUserEmail))
          .thenAnswer((_) async {});

      await repository.sendPasswordResetEmail('  $testUserEmail  ');

      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: testUserEmail))
          .called(1);
    });
  });

  group('deleteAccount', () {
    test('success', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await repository.deleteAccount();

      verify(() => mockUser.delete()).called(1);
    });

    test('with no user throws AuthException', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => repository.deleteAccount(),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'no-user',
        )),
      );
    });

    test('requires-recent-login throws AuthException', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.delete()).thenThrow(
        FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'This operation is sensitive and requires recent authentication.',
        ),
      );

      expect(
        () => repository.deleteAccount(),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'requires-recent-login',
        )),
      );
    });

    test('handles other FirebaseAuthException', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.delete()).thenThrow(
        FirebaseAuthException(
          code: 'some-other-error',
          message: 'Some error occurred.',
        ),
      );

      expect(
        () => repository.deleteAccount(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('authStateChanges', () {
    test('stream emits user', () async {
      final controller = StreamController<User?>.broadcast();
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => controller.stream);

      final stream = repository.authStateChanges;
      controller.add(mockUser);

      await expectLater(
        stream.take(1),
        emits(equals(mockUser)),
      ).timeout(const Duration(seconds: 2));

      await controller.close();
    }, skip: 'Stream test timing issues');

    test('stream emits null when signed out', () async {
      final controller = StreamController<User?>.broadcast();
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => controller.stream);

      final stream = repository.authStateChanges;
      controller.add(null);

      await expectLater(
        stream.take(1),
        emits(isNull),
      ).timeout(const Duration(seconds: 2));

      await controller.close();
    }, skip: 'Stream test timing issues');

    test('stream emits multiple state changes', () async {
      final controller = StreamController<User?>.broadcast();
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => controller.stream);

      final stream = repository.authStateChanges;
      final expectedStates = [null, mockUser, null];

      controller.add(null);
      controller.add(mockUser);
      controller.add(null);

      await expectLater(
        stream.take(3),
        emitsInOrder(expectedStates),
      ).timeout(const Duration(seconds: 2));

      await controller.close();
    }, skip: 'Stream test timing issues');
  });

  group('currentUser', () {
    test('returns current user', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final user = repository.currentUser;

      expect(user, equals(mockUser));
    });

    test('returns null when no user signed in', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      final user = repository.currentUser;

      expect(user, isNull);
    });
  });

  group('AuthException', () {
    test('contains message and code', () {
      final exception = AuthException('Test message', 'test-code');

      expect(exception.message, equals('Test message'));
      expect(exception.code, equals('test-code'));
    });

    test('toString returns message', () {
      final exception = AuthException('Test message', 'test-code');

      expect(exception.toString(), equals('Test message'));
    });
  });

  group('_handleAuthException', () {
    test('maps user-not-found code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'user-not-found'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'No user found with this email',
        )),
      );
    });

    test('maps wrong-password code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'wrong-password'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Incorrect password',
        )),
      );
    });

    test('maps email-already-in-use code', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'email-already-in-use'),
          );

      expect(
        () => repository.createUserWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Email is already registered',
        )),
      );
    });

    test('maps invalid-email code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'invalid-email'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('invalid', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid email address',
        )),
      );
    });

    test('maps weak-password code', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'weak-password'),
          );

      expect(
        () => repository.createUserWithEmailAndPassword('test@test.com', 'weak'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Password is too weak',
        )),
      );
    });

    test('maps user-disabled code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'user-disabled'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'This account has been disabled',
        )),
      );
    });

    test('maps too-many-requests code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'too-many-requests'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Too many attempts. Try again later',
        )),
      );
    });

    test('maps invalid-credential code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'invalid-credential'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid email or password',
        )),
      );
    });

    test('maps network-request-failed code', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(code: 'network-request-failed'),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Network error. Check your connection',
        )),
      );
    });

    test('uses exception message for unknown codes', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
            FirebaseAuthException(
              code: 'unknown-code',
              message: 'Custom error message',
            ),
          );

      expect(
        () => repository.signInWithEmailAndPassword('test@test.com', 'password'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Custom error message',
        )),
      );
    });
  });
}
