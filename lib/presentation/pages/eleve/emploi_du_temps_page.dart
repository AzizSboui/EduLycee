import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/emploi_du_temps.dart';
import '../../blocs/emploi_du_temps/emploi_du_temps_bloc.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

class EmploiDuTempsPage extends StatefulWidget {
  final String classeId;
  const EmploiDuTempsPage({super.key, required this.classeId});

  @override
  State<EmploiDuTempsPage> createState() => _EmploiDuTempsPageState();
}

class _EmploiDuTempsPageState extends State<EmploiDuTempsPage> {
  int _jourSelectionne = DateTime.now().weekday; // 1=Lun … 5=Ven

  static const _jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  @override
  void initState() {
    super.initState();
    context.read<EmploiDuTempsBloc>().add(LoadEmploiByClasse(widget.classeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmploiDuTempsBloc, EmploiState>(
      builder: (context, state) {
        return Column(
          children: [
            _JourSelector(
              jours: _jours,
              selected: _jourSelectionne,
              onSelect: (j) => setState(() => _jourSelectionne = j),
            ),
            Expanded(
              child: state is EmploiLoading
                  ? const AppLoading()
                  : state is EmploiLoaded
                      ? _CreneauxList(
                          creneaux: state.creneaux
                              .where((c) => c.jourSemaine == _jourSelectionne)
                              .toList()
                            ..sort((a, b) => a.heureDebut.compareTo(b.heureDebut)),
                        )
                      : const Center(child: Text('Aucun cours')),
            ),
          ],
        );
      },
    );
  }
}

// ── Sélecteur de jour ────────────────────────────────────────────────────────
class _JourSelector extends StatelessWidget {
  final List<String> jours;
  final int selected;
  final ValueChanged<int> onSelect;

  const _JourSelector({
    required this.jours,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Dates de la semaine courante
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: List.generate(5, (i) {
          final jour = i + 1;
          final date = monday.add(Duration(days: i));
          final isSelected = selected == jour;
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(jour),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      jours[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Liste des créneaux ───────────────────────────────────────────────────────
class _CreneauxList extends StatelessWidget {
  final List<CreneauHoraire> creneaux;
  const _CreneauxList({required this.creneaux});

  @override
  Widget build(BuildContext context) {
    if (creneaux.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available, size: 56, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Pas de cours ce jour',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creneaux.length,
      itemBuilder: (_, i) => _CreneauCard(creneau: creneaux[i]),
    );
  }
}

// ── Carte créneau ────────────────────────────────────────────────────────────
class _CreneauCard extends StatelessWidget {
  final CreneauHoraire creneau;
  const _CreneauCard({required this.creneau});

  Color get _color {
    if (creneau.couleur == null) return AppColors.primary;
    try {
      return Color(int.parse(creneau.couleur!, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre colorée à gauche
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Heure
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(creneau.heureDebut,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: color)),
                        const SizedBox(height: 4),
                        Container(width: 1, height: 20, color: AppColors.divider),
                        const SizedBox(height: 4),
                        Text(creneau.heureFin,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Infos matière
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            creneau.matiereId,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.room, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(creneau.salle,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Badge durée
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _duree,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _duree {
    try {
      final debut = _parseHeure(creneau.heureDebut);
      final fin = _parseHeure(creneau.heureFin);
      final diff = fin - debut;
      return '${diff}h';
    } catch (_) {
      return '2h';
    }
  }

  int _parseHeure(String h) => int.parse(h.split(':')[0]);
}
