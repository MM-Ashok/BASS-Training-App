import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/programme_model.dart';

class ProgrammeService {
  ProgrammeService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _programmes =>
      _firestore.collection('programmes');

  Stream<List<ProgrammeModel>> getProgrammes() {
    return _programmes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProgrammeModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> createProgramme(ProgrammeModel programme) async {
    await _programmes.add(programme.toMap());
  }

 Future<void> updateProgramme(ProgrammeModel programme) async {
  await _programmes.doc(programme.id).update(programme.toMap());
}

Future<void> deleteProgramme(String id) async {
  await _programmes.doc(id).delete();
}

  Future<ProgrammeModel?> getProgramme(String id) async {
    final doc = await _programmes.doc(id).get();

    if (!doc.exists) return null;

    return ProgrammeModel.fromFirestore(doc);
  }
}