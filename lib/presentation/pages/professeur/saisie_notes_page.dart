import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../themes/app_theme.dart';

class SaisieNotesPage extends StatefulWidget {
  const SaisieNotesPage({super.key});

  @override
  State<SaisieNotesPage> createState() => _SaisieNotesPageState();
}

class _SaisieNotesPageState extends State<SaisieNotesPage> {
  String _matiereSelectionnee = 'Mathématiques';
  String _typeEval = 'controle';
  double _coefficient = 2.0;
  final _titreCtrl = TextEditingController();
  bool _saving = false;

  // controllers par eleveId
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void dispose() {
    _titreCtrl.dispose();
    for (final c in _noteControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _enregistrer(List<Map<String, dynamic>> eleves) async {
    if (eleves.isEmpty) return;
    setState(() => _saving = true);

    final authState = context.read<AuthBloc>().state;
    final profId = authState is AuthAuthenticated
        ? authState.utilisateur.uid
        : 'unknown';

    int count = 0;
    final batch = FirebaseFirestore.instance.batch();

    for (final eleve in eleves) {
      final eleveId = eleve['uid'] as String;
      final ctrl = _noteControllers[eleveId];
      if (ctrl == null) continue;
      final val = double.tryParse(ctrl.text.replaceAll(',', '.'));
      if (val == null || val < 0 || val > 20) continue;

      final noteId = const Uuid().v4();
      final ref = FirebaseFirestore.instance
          .collection(AppConstants.notesCollection)
          .doc(noteId);

      batch.set(ref, {
        'id': noteId,
        'eleveId': eleveId,
        'matiereId': _matiereSelectionnee,
        'professeurId': profId,
        'valeur': val,
        'coefficient': _coefficient,
        'typeEvaluation': _typeEval,
        'titre': _titreCtrl.text.trim().isEmpty ? null : _titreCtrl.text.trim(),
        'commentaire': null,
        'date': Timestamp.now(),
        'periodeId': null,
        'competenceId': null,
      });
      count++;
    }

    await batch.commit();
    setState(() => _saving = false);

    // Vider les champs
    for (final c in _noteControllers.values) c.clear();
    _titreCtrl.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count notes enregistrées dans Firestore ✅'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: 'eleve')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final eleves = <Map<String, dynamic>>[];

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            eleves.add({
              'uid': doc.id,
              'nom': data['nom'] ?? '',
              'prenom': data['prenom'] ?? '',
            });
            // Créer controller si pas encore existant
            _noteControllers.putIfAbsent(
                doc.id, () => TextEditingController());
          }
        }

        return Column(
          children: [
            _buildConfig(),
            const SizedBox(height: 12),
            Expanded(child: _buildGrille(eleves, snapshot.connectionState)),
            _buildFooter(eleves),
          ],
        );
      },
    );
  }

  Widget _buildConfig() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
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
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _matiereSelectionnee,
                  decoration: const InputDecoration(
                      labelText: 'Matière',
                      prefixIcon: Icon(Icons.book_outlined),
                      isDense: true),
                  items: ['Mathématiques', 'Physique', 'Français',
                      'Histoire', 'Anglais', 'SVT', 'Philosophie']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _matiereSelectionnee = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<double>(
                  value: _coefficient,
                  decoration: const InputDecoration(
                      labelText: 'Coeff.',
                      isDense: true),
                  items: [1.0, 2.0, 3.0, 4.0, 5.0]
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c.toStringAsFixed(0))))
                      .toList(),
                  onChanged: (v) => setState(() => _coefficient = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _typeEval,
                  decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.assignment_outlined),
                      isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'controle', child: Text('Contrôle')),
                    DropdownMenuItem(value: 'devoir',   child: Text('Devoir')),
                    DropdownMenuItem(value: 'examen',   child: Text('Examen')),
                    DropdownMenuItem(value: 'oral',     child: Text('Oral')),
                    DropdownMenuItem(value: 'tp',       child: Text('TP')),
                  ],
                  onChanged: (v) => setState(() => _typeEval = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _titreCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Titre (optionnel)',
                      prefixIcon: Icon(Icons.title),
                      isDense: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrille(
      List<Map<String, dynamic>> eleves, ConnectionState state) {
    if (state == ConnectionState.waiting) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (eleves.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 56, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Aucun élève trouvé dans Firestore',
                style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('Créez des comptes élèves via la page d\'inscription',
                style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
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
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                    child: Text('Élève',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600))),
                Text('${eleves.length} élèves',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(width: 16),
                const SizedBox(
                    width: 90,
                    child: Text('Note /20',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Liste élèves
          Expanded(
            child: ListView.builder(
              itemCount: eleves.length,
              itemBuilder: (_, i) {
                final eleve = eleves[i];
                final eleveId = eleve['uid'] as String;
                final ctrl = _noteControllers[eleveId]!;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : const Color(0xFFF8FAFF),
                    border: const Border(
                        bottom: BorderSide(
                            color: AppColors.border, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          (eleve['prenom'] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${eleve['prenom']} ${eleve['nom']}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      // Champ note — widget isolé pour éviter rebuild global
                      _NoteField(controller: ctrl),
                    ],
                  ),
                );
              },
            ),
          ),
          // Résumé stats
          if (_noteControllers.values
              .any((c) => double.tryParse(c.text) != null))
            _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final vals = _noteControllers.values
        .map((c) => double.tryParse(c.text.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return const SizedBox();
    final moy = vals.reduce((a, b) => a + b) / vals.length;
    final min = vals.reduce((a, b) => a < b ? a : b);
    final max = vals.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip('Moy.', moy.toStringAsFixed(1), AppColors.primary),
          _StatChip('Min', min.toStringAsFixed(1), AppColors.error),
          _StatChip('Max', max.toStringAsFixed(1), AppColors.success),
          _StatChip('Saisis', '${vals.length}', AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildFooter(List<Map<String, dynamic>> eleves) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : () => _enregistrer(eleves),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save_rounded, size: 18),
          label: Text(_saving
              ? 'Enregistrement...'
              : 'Enregistrer les notes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Champ note isolé — pas de rebuild global ─────────────────────────────────
class _NoteField extends StatefulWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final val = double.tryParse(
        widget.controller.text.replaceAll(',', '.'));

    Color fieldColor = Colors.white;
    Color textColor = AppColors.textPrimary;
    if (val != null) {
      fieldColor = val >= 10
          ? AppColors.success.withValues(alpha: 0.08)
          : AppColors.error.withValues(alpha: 0.08);
      textColor = val >= 10 ? AppColors.success : AppColors.error;
    }

    return SizedBox(
      width: 90,
      child: TextField(
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: '—',
          hintStyle: const TextStyle(color: AppColors.textHint),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
    );
  }
}
