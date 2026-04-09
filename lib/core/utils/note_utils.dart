class NoteUtils {
  static double calculerMoyenne(List<Map<String, double>> notes) {
    if (notes.isEmpty) return 0.0;
    double totalPondere = 0;
    double totalCoeff = 0;
    for (final n in notes) {
      totalPondere += n['valeur']! * n['coefficient']!;
      totalCoeff += n['coefficient']!;
    }
    return totalCoeff == 0 ? 0 : totalPondere / totalCoeff;
  }

  static String getMentionColor(double moyenne) {
    if (moyenne >= 16) return 'Très Bien';
    if (moyenne >= 14) return 'Bien';
    if (moyenne >= 12) return 'Assez Bien';
    if (moyenne >= 10) return 'Passable';
    return 'Insuffisant';
  }

  static String formatNote(double note) => note.toStringAsFixed(2);
}
