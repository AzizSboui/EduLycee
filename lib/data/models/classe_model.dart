import '../../domain/entities/classe.dart';

class ClasseModel extends Classe {
  const ClasseModel({
    required super.id,
    required super.nom,
    required super.niveau,
    super.professeurPrincipalId,
    super.elevesIds,
    super.matiereIds,
    required super.anneesScolaire,
  });

  factory ClasseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ClasseModel(
      id: id,
      nom: data['nom'] ?? '',
      niveau: data['niveau'] ?? '',
      professeurPrincipalId: data['professeurPrincipalId'],
      elevesIds: List<String>.from(data['elevesIds'] ?? []),
      matiereIds: List<String>.from(data['matiereIds'] ?? []),
      anneesScolaire: data['anneesScolaire'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nom': nom,
        'niveau': niveau,
        'professeurPrincipalId': professeurPrincipalId,
        'elevesIds': elevesIds,
        'matiereIds': matiereIds,
        'anneesScolaire': anneesScolaire,
      };
}
