import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/absence.dart';

class AbsenceModel extends Absence {
  const AbsenceModel({
    required super.id,
    required super.eleveId,
    required super.date,
    required super.heureDebut,
    required super.heureFin,
    required super.type,
    super.statut,
    super.motif,
    super.justificatifUrl,
    super.matiereId,
  });

  factory AbsenceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AbsenceModel(
      id: id,
      eleveId: data['eleveId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      heureDebut: data['heureDebut'] ?? '',
      heureFin: data['heureFin'] ?? '',
      type: data['type'] == 'retard' ? TypeAbsence.retard : TypeAbsence.absence,
      statut: _parseStatut(data['statut']),
      motif: data['motif'],
      justificatifUrl: data['justificatifUrl'],
      matiereId: data['matiereId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'eleveId': eleveId,
        'date': Timestamp.fromDate(date),
        'heureDebut': heureDebut,
        'heureFin': heureFin,
        'type': type.name,
        'statut': statut.name,
        'motif': motif,
        'justificatifUrl': justificatifUrl,
        'matiereId': matiereId,
      };

  static StatutAbsence _parseStatut(String? s) {
    switch (s) {
      case 'justifiee':
        return StatutAbsence.justifiee;
      case 'enAttente':
        return StatutAbsence.enAttente;
      default:
        return StatutAbsence.nonJustifiee;
    }
  }
}
