import 'package:equatable/equatable.dart';

enum StatutAbsence { nonJustifiee, justifiee, enAttente }
enum TypeAbsence { absence, retard }

class Absence extends Equatable {
  final String id;
  final String eleveId;
  final DateTime date;
  final String heureDebut;
  final String heureFin;
  final TypeAbsence type;
  final StatutAbsence statut;
  final String? motif;
  final String? justificatifUrl;
  final String? matiereId;

  const Absence({
    required this.id,
    required this.eleveId,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.type,
    this.statut = StatutAbsence.nonJustifiee,
    this.motif,
    this.justificatifUrl,
    this.matiereId,
  });

  @override
  List<Object?> get props => [id, eleveId, date, type];
}
