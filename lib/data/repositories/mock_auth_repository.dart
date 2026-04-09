import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/auth_repository.dart';

/// Repository de démo — utilisé quand Firebase n'est pas configuré.
/// Comptes de test :
///   eleve@test.com   / 123456  → rôle élève
///   prof@test.com    / 123456  → rôle professeur
///   admin@test.com   / 123456  → rôle admin
class MockAuthRepository implements AuthRepository {
  Utilisateur? _current;

  static const _users = {
    'eleve@test.com': Utilisateur(
      uid: 'eleve-001',
      nom: 'Dupont',
      prenom: 'Lucas',
      email: 'eleve@test.com',
      role: UserRole.eleve,
      classeId: 'classe-001',
    ),
    'prof@test.com': Utilisateur(
      uid: 'prof-001',
      nom: 'Martin',
      prenom: 'Sophie',
      email: 'prof@test.com',
      role: UserRole.professeur,
      matiereIds: ['math-001'],
    ),
    'admin@test.com': Utilisateur(
      uid: 'admin-001',
      nom: 'Bernard',
      prenom: 'Jean',
      email: 'admin@test.com',
      role: UserRole.admin,
    ),
    'parent@test.com': Utilisateur(
      uid: 'parent-001',
      nom: 'Dupont',
      prenom: 'Marie',
      email: 'parent@test.com',
      role: UserRole.parent,
      enfantsIds: ['eleve-001'],
    ),
  };

  @override
  Future<Utilisateur> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = _users[email.toLowerCase()];
    if (user == null || password != '123456') {
      throw Exception('Email ou mot de passe incorrect');
    }
    _current = user;
    return user;
  }

  @override
  Future<Utilisateur> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // En mode mock, signUp retourne un utilisateur élève par défaut
    // Le rôle réel est défini dans AuthBloc via Firestore
    final user = Utilisateur(
      uid: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      nom: '',
      prenom: '',
      email: email,
      role: UserRole.eleve,
    );
    _current = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }

  @override
  Future<Utilisateur?> getCurrentUser() async => _current;

  @override
  Stream<Utilisateur?> get authStateChanges async* {
    yield _current;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {}
}
