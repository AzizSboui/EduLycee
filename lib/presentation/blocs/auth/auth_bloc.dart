import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthResetPasswordRequested>(_onResetPassword);
  }

  Future<void> _onStarted(
      AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user =
          await _authRepository.signIn(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 1. Créer compte Firebase Auth
      final user =
          await _authRepository.signUp(event.email, event.password);

      debugPrint('✅ Auth UID: ${user.uid}');

      // 2. Créer document Firestore
      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(user.uid)
          .set({
        'nom': event.nom,
        'prenom': event.prenom,
        'email': event.email,
        'role': event.role,
        'classeId': null,
        'photoUrl': null,
        'matiereIds': [],
        'enfantsIds': [],
        'isActive': true,
      });

      debugPrint('✅ Firestore document créé: utilisateurs/${user.uid}');

      // 3. Récupérer l'utilisateur complet depuis Firestore
      final fullUser = await _authRepository.getCurrentUser();
      if (fullUser != null) {
        emit(AuthAuthenticated(fullUser));
      } else {
        emit(AuthSignUpSuccess());
      }
    } catch (e) {
      debugPrint('❌ SignUp error: $e');
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onResetPassword(
      AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.resetPassword(event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Utilisateur introuvable';
    if (error.contains('wrong-password')) return 'Mot de passe incorrect';
    if (error.contains('invalid-email')) return 'Email invalide';
    if (error.contains('too-many-requests')) return 'Trop de tentatives';
    if (error.contains('email-already-in-use')) return 'Email déjà utilisé';
    if (error.contains('weak-password')) return 'Mot de passe trop faible';
    if (error.contains('incorrect')) return 'Email ou mot de passe incorrect';
    return 'Erreur de connexion';
  }
}
