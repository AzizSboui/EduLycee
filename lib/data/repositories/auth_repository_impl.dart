import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Utilisateur> signIn(String email, String password) =>
      _datasource.signIn(email, password);

  @override
  Future<Utilisateur> signUp(String email, String password) async {
    // Retourne un utilisateur minimal — Firestore est rempli par le Bloc
    final uid = await _datasource.signUpGetUid(email, password);
    return Utilisateur(
      uid: uid,
      nom: '',
      prenom: '',
      email: email,
      role: UserRole.eleve,
    );
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<Utilisateur?> getCurrentUser() => _datasource.getCurrentUser();

  @override
  Stream<Utilisateur?> get authStateChanges => _datasource.authStateChanges;

  @override
  Future<void> resetPassword(String email) =>
      _datasource.resetPassword(email);

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) =>
      _datasource.updateProfile(
          displayName: displayName, photoUrl: photoUrl);
}
