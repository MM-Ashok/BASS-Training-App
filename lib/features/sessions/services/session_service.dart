import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/session_model.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sessions Collection
  CollectionReference<Map<String, dynamic>> _sessionCollection(
    String programmeId,
    String phaseId,
  ) {
    return _firestore
        .collection('programmes')
        .doc(programmeId)
        .collection('phases')
        .doc(phaseId)
        .collection('sessions');
  }

  /// Create Session
  Future<void> createSession(SessionModel session) async {
    await _sessionCollection(
      session.programmeId,
      session.phaseId,
    ).doc(session.id).set(session.toMap());
  }

  /// Get All Sessions
  Stream<List<SessionModel>> getSessions(
    String programmeId,
    String phaseId,
  ) {
    return _sessionCollection(programmeId, phaseId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => SessionModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    });
  }

  /// Get Single Session
  Stream<SessionModel?> getSession(
    String programmeId,
    String phaseId,
    String sessionId,
  ) {
    return _sessionCollection(
      programmeId,
      phaseId,
    ).doc(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return SessionModel.fromMap(
        doc.data()!,
        doc.id,
      );
    });
  }

  /// Update Session
  Future<void> updateSession(SessionModel session) async {
    await _sessionCollection(
      session.programmeId,
      session.phaseId,
    ).doc(session.id).update(session.toMap());
  }

  /// Delete Session
  Future<void> deleteSession(
    String programmeId,
    String phaseId,
    String sessionId,
  ) async {
    await _sessionCollection(
      programmeId,
      phaseId,
    ).doc(sessionId).delete();
  }
}