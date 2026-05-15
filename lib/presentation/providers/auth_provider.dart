import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AsyncValue<User?> build() {
    // Listen to the auth state changes so we are always updated when the user logs in/out
    _auth.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
    return AsyncValue.data(_auth.currentUser);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // The authStateChanges listener will update the state automatically
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e.message ?? 'Authentication failed', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e.message ?? 'Registration failed', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
