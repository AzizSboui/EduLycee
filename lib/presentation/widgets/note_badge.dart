import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class NoteBadge extends StatelessWidget {
  final double note;
  final double? size;

  const NoteBadge({super.key, required this.note, this.size});

  Color get _color {
    if (note >= 16) return AppColors.success;
    if (note >= 12) return AppColors.secondary;
    if (note >= 10) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final s = size ?? 48;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(s / 4),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Center(
        child: Text(
          note.toStringAsFixed(1),
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: s * 0.3,
          ),
        ),
      ),
    );
  }
}
