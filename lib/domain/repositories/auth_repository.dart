import '../entities/utilisateur.dart';

abstract class AuthRepository {
  Future<Utilisateur> signIn(String email, String password);
  Future<Utilisateur> signUp(String email, String password);
  Future<void> signOut();
  Future<Utilisateur?> getCurrentUser();
  Stream<Utilisateur?> get authStateChanges;
  Future<void> resetPassword(String email);
  Future<void> updateProfile({String? displayName, String? photoUrl});
}
