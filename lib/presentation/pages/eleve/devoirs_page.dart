import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/devoir.dart';
import '../../blocs/communication/communication_bloc.dart';
import '../../blocs/communication/communication_event.dart';
import '../../blocs/communication/communication_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_loading.dart';

class DevoirsPage extends StatefulWidget {
  final String classeId;
  const DevoirsPage({super.key, required this.classeId});

  @override
  State<DevoirsPage> createState() => _DevoirsPageState();
}

class _DevoirsPageState extends State<DevoirsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CommunicationBloc>().add(LoadDevoirs(widget.classeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunicationBloc, CommunicationState>(
      builder: (context, state) {
        if (state is CommunicationLoading) return const AppLoading();
        if (state is DevoirsLoaded) {
          return _DevoirsList(devoirs: state.devoirs);
        }
        return const AppLoading();
      },
    );
  }
}

class _DevoirsList extends StatelessWidget {
  final List<Devoir> devoirs;
  const _DevoirsList({required this.devoirs});

  @override
  Widget build(BuildContext context) {
    if (devoirs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_turned_in, size: 56, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Aucun devoir en cours',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    // Trier : non expirés d'abord, puis par date de rendu
    final sorted = [...devoirs]
      ..sort((a, b) {
        if (a.isExpired && !b.isExpired) return 1;
        if (!a.isExpired && b.isExpired) return -1;
        return a.dateRendu.compareTo(b.dateRendu);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (_, i) => _DevoirCard(devoir: sorted[i]),
    );
  }
}

class _DevoirCard extends StatelessWidget {
  final Devoir devoir;
  const _DevoirCard({required this.devoir});

  int get _joursRestants =>
      devoir.dateRendu.difference(DateTime.now()).inDays;

  Color get _urgenceColor {
    if (devoir.isExpired) return AppColors.textSecondary;
    if (_joursRestants <= 1) return AppColors.error;
    if (_joursRestants <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String get _urgenceLabel {
    if (devoir.isExpired) return 'Expiré';
    if (_joursRestants == 0) return 'Aujourd\'hui';
    if (_joursRestants == 1) return 'Demain';
    return 'Dans $_joursRestants j';
  }

  @override
  Widget build(BuildContext context) {
    final color = _urgenceColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: devoir.isExpired ? AppColors.background : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: devoir.isExpired
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre urgence
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Badge matière
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            devoir.matiereId,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary),
                          ),
                        ),
                        const Spacer(),
                        // Badge urgence
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _urgenceLabel,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      devoir.titre,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: devoir.isExpired
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: devoir.isExpired
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      devoir.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'À rendre le ${devoir.dateRendu.day}/${devoir.dateRendu.month}/${devoir.dateRendu.year}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (devoir.renduEnLigne) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.upload_file,
                              size: 13, color: AppColors.accent),
                          const SizedBox(width: 4),
                          const Text('En ligne',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.accent)),
                        ],
                      ],
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
}
