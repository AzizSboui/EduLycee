import 'package:equatable/equatable.dart';

class CreneauHoraire extends Equatable {
  final String id;
  final String classeId;
  final String matiereId;
  final String professeurId;
  final String salle;
  final int jourSemaine; // 1=Lundi, 5=Vendredi
  final String heureDebut;
  final String heureFin;
  final String? couleur;

  const CreneauHoraire({
    required this.id,
    required this.classeId,
    required this.matiereId,
    required this.professeurId,
    required this.salle,
    required this.jourSemaine,
    required this.heureDebut,
    required this.heureFin,
    this.couleur,
  });

  @override
  List<Object?> get props => [id, classeId, matiereId, jourSemaine, heureDebut];
}
