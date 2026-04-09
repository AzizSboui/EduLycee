import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/absence.dart';
import '../../blocs/absences/absences_bloc.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

class AbsencesPage extends StatelessWidget {
  const AbsencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AbsencesBloc, AbsencesState>(
      listener: (context, state) {
        if (state is AbsenceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
      builder: (context, state) {
        if (state is AbsencesLoading) return const AppLoading();
        if (state is AbsencesLoaded) return _AbsencesContent(state: state);
        return const AppLoading();
      },
    );
  }
}

// ── Contenu principal ─────────────────────────────────────────────────────────
class _AbsencesContent extends StatelessWidget {
  final AbsencesLoaded state;
  const _AbsencesContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsRow(state: state),
          const SizedBox(height: 20),
          const Text('Historique',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (state.absences.isEmpty)
            const _EmptyAbsences()
          else
            ...state.absences.map((a) => _AbsenceCard(absence: a)),
        ],
      ),
    );
  }
}

// ── Ligne de stats ────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AbsencesLoaded state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Absences',
            value: '${state.totalAbsences}',
            color: AppColors.error,
            icon: Icons.event_busy_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Justifiées',
            value: '${state.absencesJustifiees}',
            color: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Retards',
            value: '${state.retards}',
            color: AppColors.warning,
            icon: Icons.schedule_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBox(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Carte absence ─────────────────────────────────────────────────────────────
class _AbsenceCard extends StatelessWidget {
  final Absence absence;
  const _AbsenceCard({required this.absence});

  Color get _statutColor {
    switch (absence.statut) {
      case StatutAbsence.justifiee:
        return AppColors.success;
      case StatutAbsence.enAttente:
        return AppColors.warning;
      case StatutAbsence.nonJustifiee:
        return AppColors.error;
    }
  }

  String get _statutLabel {
    switch (absence.statut) {
      case StatutAbsence.justifiee:
        return 'Justifiée';
      case StatutAbsence.enAttente:
        return 'En attente';
      case StatutAbsence.nonJustifiee:
        return 'Non justifiée';
    }
  }

  IconData get _typeIcon => absence.type == TypeAbsence.retard
      ? Icons.schedule_rounded
      : Icons.event_busy_rounded;

  String get _typeLabel =>
      absence.type == TypeAbsence.retard ? 'Retard' : 'Absence';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre statut
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _statutColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statutColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_typeIcon,
                                  size: 12, color: _statutColor),
                              const SizedBox(width: 4),
                              Text(_typeLabel,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _statutColor)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Statut badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statutColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_statutLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _statutColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Date + heure
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${absence.date.day}/${absence.date.month}/${absence.date.year}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${absence.heureDebut} – ${absence.heureFin}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (absence.matiereId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.book_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(absence.matiereId!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                    if (absence.motif != null &&
                        absence.motif!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Motif : ${absence.motif}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                    // Bouton justifier si non justifiée
                    if (absence.statut == StatutAbsence.nonJustifiee) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showJustifierDialog(context, absence),
                          icon: const Icon(Icons.edit_note_rounded,
                              size: 16),
                          label: const Text('Soumettre un motif'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJustifierDialog(BuildContext context, Absence absence) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Justifier l\'absence',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Absence du ${absence.date.day}/${absence.date.month}/${absence.date.year}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motif de l\'absence...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context
                    .read<AbsencesBloc>()
                    .add(AbsenceJustifier(absence.id, ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────────────────────
class _EmptyAbsences extends StatelessWidget {
  const _EmptyAbsences();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  size: 56, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            const Text('Aucune absence',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Continuez comme ça !',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
