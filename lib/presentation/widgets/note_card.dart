import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../themes/app_theme.dart';
import '../../core/utils/date_utils.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final String? matiereName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.matiereName,
    this.onTap,
    this.onDelete,
  });

  Color _getNoteColor(double valeur) {
    if (valeur >= 16) return AppColors.success;
    if (valeur >= 12) return AppColors.primary;
    if (valeur >= 10) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getNoteColor(note.valeur).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    note.valeur.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getNoteColor(note.valeur),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.titre ?? matiereName ?? 'Note',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _TypeChip(type: note.typeEvaluation),
                        const SizedBox(width: 8),
                        Text(
                          'Coeff. ${note.coefficient}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (note.commentaire != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        note.commentaire!,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppDateUtils.formatDate(note.date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final TypeEvaluation type;
  const _TypeChip({required this.type});

  String get label {
    switch (type) {
      case TypeEvaluation.devoir:
        return 'Devoir';
      case TypeEvaluation.controle:
        return 'Contrôle';
      case TypeEvaluation.examen:
        return 'Examen';
      case TypeEvaluation.oral:
        return 'Oral';
      case TypeEvaluation.tp:
        return 'TP';
      case TypeEvaluation.projet:
        return 'Projet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
