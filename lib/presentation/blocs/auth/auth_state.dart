import 'package:equatable/equatable.dart';
import '../../../domain/entities/utilisateur.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Utilisateur utilisateur;
  const AuthAuthenticated(this.utilisateur);
  @override
  List<Object?> get props => [utilisateur];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {}

class AuthSignUpSuccess extends AuthState {}
