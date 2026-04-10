import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/absence.dart';
import '../../../domain/entities/emploi_du_temps.dart';
import '../../blocs/absences/absences_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

enum _Presence { present, absent, retard }

class AppelPage extends StatefulWidget {
  const AppelPage({super.key});

  @override
  State<AppelPage> createState() => _AppelPageState();
}

class _AppelPageState extends State<AppelPage> {
  CreneauHoraire? _creneauSelectionne;
  final Map<String, _Presence> _presences = {};
  final Set<String> _initialized = {};
  bool _saving = false;

  void _initPresences(List<Map<String, dynamic>> eleves) {
    for (final e in eleves) {
      final uid = e['uid'] as String;
      if (!_initialized.contains(uid)) {
        _presences[uid] = _Presence.present;
        _initialized.add(uid);
      }
    }
  }

  void _togglePresence(String uid) {
    setState(() {
      final current = _presences[uid] ?? _Presence.present;
      _presences[uid] = switch (current) {
        _Presence.present => _Presence.absent,
        _Presence.absent  => _Presence.retard,
        _Presence.retard  => _Presence.present,
      };
    });
  }

  Future<void> _enregistrerAppel(List<Map<String, dynamic>> eleves) async {
    if (_creneauSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sélectionnez un créneau d\'abord'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _saving = true);
    final creneau = _creneauSelectionne!;
    final bloc = context.read<AbsencesBloc>();

    for (final eleve in eleves) {
      final uid = eleve['uid'] as String;
      final presence = _presences[uid] ?? _Presence.present;
      if (presence == _Presence.present) continue;
      bloc.add(AbsenceSignaler(Absence(
        id: const Uuid().v4(),
        eleveId: uid,
        date: DateTime.now(),
        heureDebut: creneau.heureDebut,
        heureFin: creneau.heureFin,
        type: presence == _Presence.retard
            ? TypeAbsence.retard
            : TypeAbsence.absence,
        statut: StatutAbsence.nonJustifiee,
        matiereId: creneau.matiereId,
      )));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final nb = _presences.values.where((p) => p != _Presence.present).length;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Appel validé — $nb absence(s)/retard(s)'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));

    setState(() {
      _saving = false;
      _creneauSelectionne = null;
      _presences.clear();
      _initialized.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final profId = authState is AuthAuthenticated
        ? authState.utilisateur.uid
        : '';

    return StreamBuilder<QuerySnapshot>(
      stream: _elevesStream(),
      builder: (context, elevesSnap) {
        final eleves = <Map<String, dynamic>>[];
        if (elevesSnap.hasData) {
          for (final doc in elevesSnap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            eleves.add({
              'uid': doc.id,
              'prenom': d['prenom'] ?? '',
              'nom': d['nom'] ?? '',
            });
          }
          _initPresences(eleves);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _creneauxStream(profId),
          builder: (context, creneauxSnap) {
            final creneaux = <CreneauHoraire>[];
            if (creneauxSnap.hasData) {
              for (final doc in creneauxSnap.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                creneaux.add(CreneauHoraire(
                  id: doc.id,
                  classeId: d['classeId'] ?? '',
                  matiereId: d['matiereId'] ?? '',
                  professeurId: d['professeurId'] ?? '',
                  salle: d['salle'] ?? '',
                  jourSemaine: (d['jourSemaine'] as num?)?.toInt() ?? 1,
                  heureDebut: d['heureDebut'] ?? '',
                  heureFin: d['heureFin'] ?? '',
                  couleur: d['couleur'],
                ));
              }
            }

            return Column(
              children: [
                _buildCreneauSelector(creneaux, creneauxSnap.connectionState),
                const Divider(height: 1),
                _buildResume(eleves),
                Expanded(
                    child: _buildListe(eleves, elevesSnap.connectionState)),
                _buildFooter(eleves),
              ],
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _elevesStream() {
    try {
      return FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: 'eleve')
          .where('isActive', isEqualTo: true)
          .snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Stream<QuerySnapshot> _creneauxStream(String profId) {
    if (profId.isEmpty) return const Stream.empty();
    try {
      // On charge tous les créneaux — le prof peut voir et choisir
      return FirebaseFirestore.instance
          .collection(AppConstants.emploiDuTempsCollection)
          .snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  void _showAjouterCreneauDialog(BuildContext context) {
    final matiereCtrl = TextEditingController();
    final salleCtrl = TextEditingController();
    String jourSelectionne = 'Lundi';
    String heureDebut = '08:00';
    String heureFin = '10:00';
    final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
    final heures = ['07:00','08:00','09:00','10:00','11:00','12:00',
                    '13:00','14:00','15:00','16:00','17:00','18:00'];

    final authState = context.read<AuthBloc>().state;
    final profId = authState is AuthAuthenticated
        ? authState.utilisateur.uid
        : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Nouveau créneau',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: matiereCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Matière',
                      prefixIcon: Icon(Icons.book_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: salleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Salle',
                      prefixIcon: Icon(Icons.room_outlined)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: jourSelectionne,
                  decoration: const InputDecoration(labelText: 'Jour'),
                  items: jours
                      .map((j) =>
                          DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => jourSelectionne = v!),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: heureDebut,
                      decoration:
                          const InputDecoration(labelText: 'Début'),
                      items: heures
                          .map((h) => DropdownMenuItem(
                              value: h, child: Text(h)))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => heureDebut = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: heureFin,
                      decoration: const InputDecoration(labelText: 'Fin'),
                      items: heures
                          .map((h) => DropdownMenuItem(
                              value: h, child: Text(h)))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => heureFin = v!),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (matiereCtrl.text.trim().isEmpty) return;
                final jourIndex = jours.indexOf(jourSelectionne) + 1;
                try {
                  await FirebaseFirestore.instance
                      .collection(AppConstants.emploiDuTempsCollection)
                      .add({
                    'matiereId': matiereCtrl.text.trim(),
                    'salle': salleCtrl.text.trim().isEmpty
                        ? '—'
                        : salleCtrl.text.trim(),
                    'professeurId': profId,
                    'classeId': '',
                    'jourSemaine': jourIndex,
                    'heureDebut': heureDebut,
                    'heureFin': heureFin,
                    'couleur': null,
                  });
                } catch (_) {}
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreneauSelector(      List<CreneauHoraire> creneaux, ConnectionState connState) {
    final jours = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];
    final loading = connState == ConnectionState.waiting;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.schedule_rounded,
                size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            const Text('Créneau',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            if (loading) ...[
              const SizedBox(width: 10),
              const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary)),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () => _showAjouterCreneauDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Ajouter',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          if (!loading && creneaux.isEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Aucun créneau — créez-en un avec le bouton +',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAjouterCreneauDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: creneaux.map((c) {
                  final sel = _creneauSelectionne?.id == c.id;
                  final jour =
                      c.jourSemaine >= 1 && c.jourSemaine <= 5
                          ? jours[c.jourSemaine]
                          : '';
                  return GestureDetector(
                    onTap: () => setState(() => _creneauSelectionne = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.matiereId,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            '$jour  ${c.heureDebut}–${c.heureFin}  •  ${c.salle}',
                            style: TextStyle(
                                fontSize: 11,
                                color: sel
                                    ? Colors.white70
                                    : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_creneauSelectionne != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  '${_creneauSelectionne!.matiereId} — ${_creneauSelectionne!.heureDebut} à ${_creneauSelectionne!.heureFin}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildResume(List<Map<String, dynamic>> eleves) {
    final absents =
        _presences.values.where((p) => p == _Presence.absent).length;
    final retards =
        _presences.values.where((p) => p == _Presence.retard).length;
    final presents = eleves.length - absents - retards;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFF8FAFF),
      child: Row(children: [
        _SummaryChip(
            label: 'Présents', count: presents, color: AppColors.success),
        const SizedBox(width: 12),
        _SummaryChip(
            label: 'Absents', count: absents, color: AppColors.error),
        const SizedBox(width: 12),
        _SummaryChip(
            label: 'Retards', count: retards, color: AppColors.warning),
        const Spacer(),
        Text('${eleves.length} élèves',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildListe(
      List<Map<String, dynamic>> eleves, ConnectionState connState) {
    if (connState == ConnectionState.waiting && eleves.isEmpty) {
      return const AppLoading();
    }
    if (eleves.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Aucun élève trouvé',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: eleves.length,
      itemBuilder: (_, i) {
        final eleve = eleves[i];
        final uid = eleve['uid'] as String;
        final presence = _presences[uid] ?? _Presence.present;
        return _EleveAppelRow(
          prenom: eleve['prenom'] as String,
          nom: eleve['nom'] as String,
          presence: presence,
          onTap: () => _togglePresence(uid),
        );
      },
    );
  }

  Widget _buildFooter(List<Map<String, dynamic>> eleves) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : () => _enregistrerAppel(eleves),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.how_to_reg_rounded, size: 18),
          label: Text(_saving ? 'Enregistrement...' : 'Valider l\'appel'),
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

// ── Ligne élève ───────────────────────────────────────────────────────────────
class _EleveAppelRow extends StatelessWidget {
  final String prenom;
  final String nom;
  final _Presence presence;
  final VoidCallback onTap;

  const _EleveAppelRow({
    required this.prenom,
    required this.nom,
    required this.presence,
    required this.onTap,
  });

  Color get _color => switch (presence) {
        _Presence.present => AppColors.success,
        _Presence.absent  => AppColors.error,
        _Presence.retard  => AppColors.warning,
      };

  IconData get _icon => switch (presence) {
        _Presence.present => Icons.check_circle_rounded,
        _Presence.absent  => Icons.cancel_rounded,
        _Presence.retard  => Icons.schedule_rounded,
      };

  String get _label => switch (presence) {
        _Presence.present => 'Présent',
        _Presence.absent  => 'Absent',
        _Presence.retard  => 'Retard',
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.04),
          border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _color.withValues(alpha: 0.15),
            child: Text(
              prenom.isNotEmpty ? prenom[0].toUpperCase() : '?',
              style: TextStyle(
                  color: _color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$prenom $nom',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 14, color: _color),
                const SizedBox(width: 5),
                Text(_label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _color)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Résumé chip ───────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text('$count $label',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]);
  }
}
