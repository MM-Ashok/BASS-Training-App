import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import 'firestore_paths.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createEntry(
      String orgId, String programmeId, FeedbackEntry entry) async {
    final ref = await _db
        .collection(FirestorePaths.feedbackEntries(orgId, programmeId, entry.sessionId))
        .add(entry.toMap());
    return ref.id;
  }

  Stream<List<FeedbackEntry>> watchForSession(
      String orgId, String programmeId, String sessionId) {
    return _db
        .collection(FirestorePaths.feedbackEntries(orgId, programmeId, sessionId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FeedbackEntry.fromMap(d.id, d.data())).toList());
  }

  /// Cross-reference: every feedback entry for a trainee that mentions a
  /// given skill tag, across all sessions/programmes. Uses a
  /// collectionGroup query since entries are nested under sessions.
  Stream<List<FeedbackEntry>> watchForTraineeBySkill(String orgId, String traineeId,
      {String? skillTagId}) {
    Query<Map<String, dynamic>> q = _db
        .collectionGroup('feedbackEntries')
        .where('traineeId', isEqualTo: traineeId);
    if (skillTagId != null) {
      q = q.where('skillTagIds', arrayContains: skillTagId);
    }
    return q
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FeedbackEntry.fromMap(d.id, d.data())).toList());
  }

  // ---------------- Skill tags ----------------

  Future<String> createSkillTag(String orgId, SkillTag tag) async {
    final ref = await _db.collection(FirestorePaths.skillTags(orgId)).add(tag.toMap());
    return ref.id;
  }

  Stream<List<SkillTag>> watchSkillTags(String orgId) {
    return _db
        .collection(FirestorePaths.skillTags(orgId))
        .snapshots()
        .map((snap) => snap.docs.map((d) => SkillTag.fromMap(d.id, d.data())).toList());
  }
}
