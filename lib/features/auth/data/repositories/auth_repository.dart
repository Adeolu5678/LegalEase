import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<UserCredential> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}
