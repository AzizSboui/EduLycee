import '../../domain/entities/matiere.dart';

class MatiereModel extends Matiere {
  const MatiereModel({
    required super.id,
    required super.nom,
    required super.code,
    required super.coefficient,
    super.couleur,
    super.icone,
  });

  factory MatiereModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MatiereModel(
      id: id,
      nom: data['nom'] ?? '',
      code: data['code'] ?? '',
      coefficient: (data['coefficient'] ?? 1).toDouble(),
      couleur: data['couleur'],
      icone: data['icone'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nom': nom,
        'code': code,
        'coefficient': coefficient,
        'couleur': couleur,
        'icone': icone,
      };
}
