import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/phase_model.dart';

class PhaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _phaseCollection(
      String programmeId) {
    return _firestore
        .collection('programmes')
        .doc(programmeId)
        .collection('phases');
  }

  Future<void> createPhase(PhaseModel phase) async {
    await _phaseCollection(phase.programmeId)
        .doc(phase.id)
        .set(phase.toMap());
  }

  Stream<List<PhaseModel>> getPhases(String programmeId) {
    return _phaseCollection(programmeId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PhaseModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ADD THIS METHOD INSIDE THE CLASS
  Stream<PhaseModel?> getPhaseStream(
    String programmeId,
    String phaseId,
  ) {
    return _phaseCollection(programmeId)
        .doc(phaseId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      return PhaseModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<PhaseModel?> getPhase(
    String programmeId,
    String phaseId,
  ) async {
    final doc = await _phaseCollection(programmeId).doc(phaseId).get();

    if (!doc.exists) return null;

    return PhaseModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updatePhase(PhaseModel phase) async {
    await _phaseCollection(phase.programmeId)
        .doc(phase.id)
        .update(phase.toMap());
  }

  Future<void> deletePhase(
    String programmeId,
    String phaseId,
  ) async {
    await _phaseCollection(programmeId)
        .doc(phaseId)
        .delete();
  }
}