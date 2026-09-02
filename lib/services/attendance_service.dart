import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import 'firestore_paths.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> markAttendance(String orgId, String programmeId, AttendanceRecord record) {
    return _db
        .collection(FirestorePaths.attendance(orgId, programmeId, record.sessionId))
        .doc('${record.sessionId}_${record.traineeId}') // one record per trainee per session
        .set(record.toMap());
  }

  Stream<List<AttendanceRecord>> watchForSession(
      String orgId, String programmeId, String sessionId) {
    return _db
        .collection(FirestorePaths.attendance(orgId, programmeId, sessionId))
        .snapshots()
        .map((snap) => snap.docs.map((d) => AttendanceRecord.fromMap(d.id, d.data())).toList());
  }

  /// Attendance history for one trainee across a programme — requires
  /// scanning each session's attendance subcollection since attendance is
  /// nested under sessions. For the scaffold this is done client-side
  /// with collectionGroup; in production, consider denormalizing a
  /// per-trainee attendance summary doc to avoid the collectionGroup scan.
  Stream<List<AttendanceRecord>> watchForTrainee(String orgId, String traineeId) {
    return _db
        .collectionGroup('attendance')
        .where('traineeId', isEqualTo: traineeId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AttendanceRecord.fromMap(d.id, d.data())).toList());
  }
}
