import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers.dart';

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.session?.user ??
      Supabase.instance.client.auth.currentUser;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncData(null));

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      state = const AsyncData(null);
    } on AuthApiException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncError(
          'Sign-in failed. Please check your connection and try again.',
          StackTrace.current);
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      state = const AsyncData(null);
    } on AuthApiException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncError('Sign-up failed: ${e.toString()}', StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _client.auth.signOut();
      // Requirement: On sign-out or account switch, wipe the local Drift DB so one user's cache never shows for another.
      await _ref.read(itemRepositoryProvider).wipeLocalData();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError('Sign-out error: $e', StackTrace.current);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});
