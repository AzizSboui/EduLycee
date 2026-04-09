import 'package:equatable/equatable.dart';

enum UserRole { eleve, professeur, parent, admin, vieScolaire }

class Utilisateur extends Equatable {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final String? classeId;
  final List<String> matiereIds;
  final List<String> enfantsIds;
  final bool isActive;

  const Utilisateur({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.photoUrl,
    this.classeId,
    this.matiereIds = const [],
    this.enfantsIds = const [],
    this.isActive = true,
  });

  String get fullName => '$prenom $nom';

  @override
  List<Object?> get props =>
      [uid, nom, prenom, email, role, photoUrl, classeId];
}
