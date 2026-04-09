import 'package:equatable/equatable.dart';

class Classe extends Equatable {
  final String id;
  final String nom;
  final String niveau;
  final String? professeurPrincipalId;
  final List<String> elevesIds;
  final List<String> matiereIds;
  final String anneesScolaire;

  const Classe({
    required this.id,
    required this.nom,
    required this.niveau,
    this.professeurPrincipalId,
    this.elevesIds = const [],
    this.matiereIds = const [],
    required this.anneesScolaire,
  });

  @override
  List<Object?> get props => [id, nom, niveau];
}
