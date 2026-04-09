import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/note_model.dart';

class NotesDatasource {
  final FirebaseFirestore _firestore;

  NotesDatasource(this._firestore);

  Stream<List<NoteModel>> getNotesByEleve(String eleveId, {String? periodeId}) {
    Query query = _firestore
        .collection(AppConstants.notesCollection)
        .where('eleveId', isEqualTo: eleveId)
        .orderBy('date', descending: true);
    if (periodeId != null) {
      query = query.where('periodeId', isEqualTo: periodeId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => NoteModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Stream<List<NoteModel>> getNotesByClasse(String classeId, String matiereId) {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('classeId', isEqualTo: classeId)
        .where('matiereId', isEqualTo: matiereId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NoteModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<void> ajouterNote(NoteModel note) async {
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(note.id)
        .set(note.toFirestore());
  }

  Future<void> modifierNote(NoteModel note) async {
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(note.id)
        .update(note.toFirestore());
  }

  Future<void> supprimerNote(String noteId) async {
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(noteId)
        .delete();
  }

  Future<List<NoteModel>> getNotesListByEleve(String eleveId, {String? periodeId}) async {
    Query query = _firestore
        .collection(AppConstants.notesCollection)
        .where('eleveId', isEqualTo: eleveId);
    if (periodeId != null) {
      query = query.where('periodeId', isEqualTo: periodeId);
    }
    final snap = await query.get();
    return snap.docs
        .map((d) => NoteModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }
}
