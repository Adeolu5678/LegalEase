import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/auth/data/repositories/auth_repository.dart';
import 'package:legalease/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:legalease/features/auth/domain/entities/user_entity.dart';
import 'package:legalease/features/subscription/domain/providers/subscription_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;

  final isPremium = ref.watch(isPremiumUserProvider);

  return UserEntity(
    id: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    isAnonymous: user.isAnonymous,
    isPremium: isPremium,
    createdAt: user.metadata.creationTime ?? DateTime.now(),
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateChangesProvider).value != null;
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<User?>>(
      authStateChangesProvider,
      (_, next) {
        state = next.when(
          data: (user) {
            if (user == null) {
              return const AsyncValue.data(null);
            }
            final isPremium = _ref.read(isPremiumUserProvider);
            return AsyncValue.data(UserEntity(
              id: user.uid,
              email: user.email,
              displayName: user.displayName,
              photoUrl: user.photoURL,
              isAnonymous: user.isAnonymous,
              isPremium: isPremium,
              createdAt: user.metadata.creationTime ?? DateTime.now(),
            ));
          },
          loading: () => const AsyncValue.loading(),
          error: (error, stack) => AsyncValue.error(error, stack),
        );
      },
      fireImmediately: true,
    );
  }

  Future<void> _refreshSubscription() async {
    await _ref.read(subscriptionScreenViewModelProvider.notifier).retry();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.signInWithEmailAndPassword(email, password);
      await _refreshSubscription();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.createUserWithEmailAndPassword(email, password);
      await _refreshSubscription();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.signInWithGoogle();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.signInWithApple();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.signInAnonymously();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
