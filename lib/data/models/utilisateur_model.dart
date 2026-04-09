import '../../domain/entities/utilisateur.dart';

class UtilisateurModel extends Utilisateur {
  const UtilisateurModel({
    required super.uid,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.role,
    super.photoUrl,
    super.classeId,
    super.matiereIds,
    super.enfantsIds,
    super.isActive,
  });

  factory UtilisateurModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UtilisateurModel(
      uid: id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      photoUrl: data['photoUrl'],
      classeId: data['classeId'],
      matiereIds: List<String>.from(data['matiereIds'] ?? []),
      enfantsIds: List<String>.from(data['enfantsIds'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'role': role.name,
        'photoUrl': photoUrl,
        'classeId': classeId,
        'matiereIds': matiereIds,
        'enfantsIds': enfantsIds,
        'isActive': isActive,
      };

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'professeur':
        return UserRole.professeur;
      case 'parent':
        return UserRole.parent;
      case 'admin':
        return UserRole.admin;
      case 'vie_scolaire':
        return UserRole.vieScolaire;
      default:
        return UserRole.eleve;
    }
  }
}
