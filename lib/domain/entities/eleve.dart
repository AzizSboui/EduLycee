import 'package:equatable/equatable.dart';

enum StatutScolaire { actif, inactif, transfere, diplome }

class Eleve extends Equatable {
  final String uid;
  final String nom;
  final String prenom;
  final String classeId;
  final String? photoUrl;
  final List<String> parentsIds;
  final DateTime dateInscription;
  final StatutScolaire statut;
  final String? numeroEtudiant;

  const Eleve({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.classeId,
    this.photoUrl,
    this.parentsIds = const [],
    required this.dateInscription,
    this.statut = StatutScolaire.actif,
    this.numeroEtudiant,
  });

  String get fullName => '$prenom $nom';

  @override
  List<Object?> get props => [uid, nom, prenom, classeId];
}
