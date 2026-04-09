import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.eleveId,
    required super.matiereId,
    required super.professeurId,
    required super.valeur,
    required super.coefficient,
    required super.typeEvaluation,
    super.commentaire,
    required super.date,
    super.competenceId,
    super.periodeId,
    super.titre,
  });

  factory NoteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NoteModel(
      id: id,
      eleveId: data['eleveId'] ?? '',
      matiereId: data['matiereId'] ?? '',
      professeurId: data['professeurId'] ?? '',
      valeur: (data['valeur'] ?? 0).toDouble(),
      coefficient: (data['coefficient'] ?? 1).toDouble(),
      typeEvaluation: _parseType(data['typeEvaluation']),
      commentaire: data['commentaire'],
      date: (data['date'] as Timestamp).toDate(),
      competenceId: data['competenceId'],
      periodeId: data['periodeId'],
      titre: data['titre'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'eleveId': eleveId,
        'matiereId': matiereId,
        'professeurId': professeurId,
        'valeur': valeur,
        'coefficient': coefficient,
        'typeEvaluation': typeEvaluation.name,
        'commentaire': commentaire,
        'date': Timestamp.fromDate(date),
        'competenceId': competenceId,
        'periodeId': periodeId,
        'titre': titre,
      };

  static TypeEvaluation _parseType(String? type) {
    switch (type) {
      case 'controle':
        return TypeEvaluation.controle;
      case 'examen':
        return TypeEvaluation.examen;
      case 'oral':
        return TypeEvaluation.oral;
      case 'tp':
        return TypeEvaluation.tp;
      case 'projet':
        return TypeEvaluation.projet;
      default:
        return TypeEvaluation.devoir;
    }
  }
}
