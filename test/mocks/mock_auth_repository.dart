import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:legalease/features/auth/data/repositories/auth_repository.dart';

class FakeIdTokenResult extends Fake implements IdTokenResult {
  @override
  String? get token => 'mock-id-token';

  @override
  Map<String, dynamic>? get claims => {};

  @override
  DateTime? get authTime => null;

  @override
  DateTime? get issuedAtTime => DateTime.now();

  @override
  DateTime? get expirationTime => DateTime.now().add(const Duration(hours: 1));

  @override
  String? get signInProvider => 'password';

  @override
  String? get signInSecondFactor => null;
}

class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final String? photoURL;

  @override
  final bool emailVerified;

  @override
  final bool isAnonymous;

  @override
  final String? phoneNumber;

  @override
  final String? providerId;

  FakeUser({
    this.uid = 'test-user-id',
    this.email = 'test@example.com',
    this.displayName = 'Test User',
    this.photoURL,
    this.emailVerified = true,
    this.isAnonymous = false,
    this.phoneNumber,
    this.providerId = 'firebase',
  });

  @override
  Future<void> reload() async {}

  @override
  Future<void> delete() async {}

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updatePhotoURL(String? photoURL) async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock-id-token';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => FakeIdTokenResult();

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
  final User? _user;

  MockAuthRepository._({User? user}) : _user = user;

  factory MockAuthRepository.withSignedInUser({User? user}) {
    final mock = MockAuthRepository._(user: user ?? FakeUser());
    when(() => mock.authStateChanges).thenAnswer((_) => Stream.value(mock._user));
    when(() => mock.currentUser).thenReturn(mock._user);
    when(() => mock.signInWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => FakeUserCredential(user: mock._user));
    when(() => mock.createUserWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => FakeUserCredential(user: mock._user));
    when(() => mock.signInWithGoogle())
        .thenAnswer((_) async => FakeUserCredential(user: mock._user));
    when(() => mock.signInWithApple())
        .thenAnswer((_) async => FakeUserCredential(user: mock._user));
    when(() => mock.signInAnonymously())
        .thenAnswer((_) async => FakeUserCredential(user: FakeUser(isAnonymous: true)));
    when(() => mock.signOut()).thenAnswer((_) async {});
    when(() => mock.sendPasswordResetEmail(any())).thenAnswer((_) async {});
    when(() => mock.deleteAccount()).thenAnswer((_) async {});
    return mock;
  }

  factory MockAuthRepository.signedOut() {
    final mock = MockAuthRepository._();
    when(() => mock.authStateChanges).thenAnswer((_) => Stream.value(null));
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

  factory MockAuthRepository.withError(Exception exception) {
    final mock = MockAuthRepository._();
    when(() => mock.authStateChanges).thenAnswer((_) => Stream.value(null));
    when(() => mock.currentUser).thenReturn(null);
    when(() => mock.signInWithEmailAndPassword(any(), any()))
        .thenThrow(exception);
    when(() => mock.createUserWithEmailAndPassword(any(), any()))
        .thenThrow(exception);
    when(() => mock.signInWithGoogle()).thenThrow(exception);
    when(() => mock.signInWithApple()).thenThrow(exception);
    when(() => mock.signInAnonymously()).thenThrow(exception);
    when(() => mock.signOut()).thenThrow(exception);
    when(() => mock.sendPasswordResetEmail(any())).thenThrow(exception);
    when(() => mock.deleteAccount()).thenThrow(exception);
    return mock;
  }
}
