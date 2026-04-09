import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const AppLoading();
    final eleveId = authState.utilisateur.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.notesCollection)
          .where('eleveId', isEqualTo: eleveId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error)),
          );
        }

        final notes = snapshot.data?.docs ?? [];

        if (notes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.grade_outlined,
                    size: 64, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text('Aucune note disponible',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textSecondary)),
                SizedBox(height: 8),
                Text('Vos notes apparaîtront ici',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textHint)),
              ],
            ),
          );
        }

        // Grouper par matière
        final Map<String, List<Map<String, dynamic>>> byMatiere = {};
        for (final doc in notes) {
          final data = doc.data() as Map<String, dynamic>;
          final matiere = data['matiereId'] as String? ?? 'Inconnue';
          byMatiere.putIfAbsent(matiere, () => []).add(data);
        }

        // Calculer moyennes
        final Map<String, double> moyennes = {};
        double totalMoy = 0;
        for (final entry in byMatiere.entries) {
          double total = 0, coeff = 0;
          for (final n in entry.value) {
            total += (n['valeur'] as num).toDouble() *
                (n['coefficient'] as num).toDouble();
            coeff += (n['coefficient'] as num).toDouble();
          }
          moyennes[entry.key] = coeff == 0 ? 0 : total / coeff;
          totalMoy += moyennes[entry.key]!;
        }
        final moyenneGenerale =
            moyennes.isEmpty ? 0.0 : totalMoy / moyennes.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MoyenneCard(moyenne: moyenneGenerale),
              const SizedBox(height: 16),
              if (notes.length >= 2) ...[
                _ProgressionChart(notes: notes
                    .map((d) => d.data() as Map<String, dynamic>)
                    .toList()),
                const SizedBox(height: 16),
              ],
              const Text('Par matière',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...byMatiere.entries.map((entry) => _MatiereSection(
                    matiere: entry.key,
                    notes: entry.value,
                    moyenne: moyennes[entry.key] ?? 0,
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ── Carte moyenne générale ───────────────────────────────────────────────────
class _MoyenneCard extends StatelessWidget {
  final double moyenne;
  const _MoyenneCard({required this.moyenne});

  Color get _color {
    if (moyenne >= 16) return AppColors.success;
    if (moyenne >= 12) return AppColors.secondary;
    if (moyenne >= 10) return const Color(0xFFF59E0B);
    return AppColors.error;
  }

  String get _mention {
    if (moyenne >= 16) return 'Très Bien';
    if (moyenne >= 14) return 'Bien';
    if (moyenne >= 12) return 'Assez Bien';
    if (moyenne >= 10) return 'Passable';
    return 'Insuffisant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_color, _color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Moyenne générale',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(moyenne.toStringAsFixed(2),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold)),
              Text(_mention,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.emoji_events_rounded,
              color: Colors.white54, size: 60),
        ],
      ),
    );
  }
}

// ── Graphique progression ────────────────────────────────────────────────────
class _ProgressionChart extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  const _ProgressionChart({required this.notes});

  @override
  Widget build(BuildContext context) {
    final sorted = [...notes]..sort((a, b) {
        final da = (a['date'] as Timestamp).toDate();
        final db = (b['date'] as Timestamp).toDate();
        return da.compareTo(db);
      });
    final recent =
        sorted.length > 10 ? sorted.sublist(sorted.length - 10) : sorted;
    final spots = recent.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(),
          (e.value['valeur'] as num).toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progression récente',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 20,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

// ── Section matière ──────────────────────────────────────────────────────────
class _MatiereSection extends StatelessWidget {
  final String matiere;
  final List<Map<String, dynamic>> notes;
  final double moyenne;
  const _MatiereSection(
      {required this.matiere,
      required this.notes,
      required this.moyenne});

  Color get _moyColor {
    if (moyenne >= 16) return AppColors.success;
    if (moyenne >= 12) return AppColors.secondary;
    if (moyenne >= 10) return const Color(0xFFF59E0B);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(matiere,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _moyColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _moyColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                moyenne.toStringAsFixed(1),
                style: TextStyle(
                    color: _moyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more,
                color: AppColors.textSecondary),
          ],
        ),
        children: notes.map((n) => _NoteItem(note: n)).toList(),
      ),
    );
  }
}

// ── Item note ────────────────────────────────────────────────────────────────
class _NoteItem extends StatelessWidget {
  final Map<String, dynamic> note;
  const _NoteItem({required this.note});

  Color get _color {
    final v = (note['valeur'] as num).toDouble();
    if (v >= 16) return AppColors.success;
    if (v >= 12) return AppColors.secondary;
    if (v >= 10) return const Color(0xFFF59E0B);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final valeur = (note['valeur'] as num).toDouble();
    final coeff = (note['coefficient'] as num).toDouble();
    final date = (note['date'] as Timestamp).toDate();
    final titre = note['titre'] as String?;
    final type = note['typeEvaluation'] as String? ?? 'devoir';
    final commentaire = note['commentaire'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Badge note
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                valeur.toStringAsFixed(1),
                style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre ?? _typeLabel(type),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      fontSize: 14),
                ),
                Text(
                  'Coeff. $coeff • ${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
                if (commentaire != null && commentaire.isNotEmpty)
                  Text(commentaire,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'controle': return 'Contrôle';
      case 'examen':   return 'Examen';
      case 'oral':     return 'Oral';
      case 'tp':       return 'TP';
      case 'projet':   return 'Projet';
      default:         return 'Devoir';
    }
  }
}
