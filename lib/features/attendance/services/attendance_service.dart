import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Attendance collection reference
  CollectionReference<Map<String, dynamic>> _attendanceCollection(
    String programmeId,
    String phaseId,
    String sessionId,
  ) {
    return _firestore
        .collection('programmes')
        .doc(programmeId)
        .collection('phases')
        .doc(phaseId)
        .collection('sessions')
        .doc(sessionId)
        .collection('attendance');
  }

  /// Create Attendance
  Future<void> createAttendance(AttendanceModel attendance) async {
    await _attendanceCollection(
      attendance.programmeId,
      attendance.phaseId,
      attendance.sessionId,
    ).doc(attendance.id).set(attendance.toMap());
  }

  /// Get all attendance for a session
  Stream<List<AttendanceModel>> getAttendance(
  String programmeId,
  String phaseId,
  String sessionId,
) {
  print("Listening attendance:");
  print(programmeId);
  print(phaseId);
  print(sessionId);

  return _attendanceCollection(
    programmeId,
    phaseId,
    sessionId,
  ).snapshots().map((snapshot) {
    print("Attendance docs: ${snapshot.docs.length}");

    return snapshot.docs
        .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
        .toList();
  });
}

  /// Get single attendance record
  Future<AttendanceModel?> getAttendanceRecord(
    String programmeId,
    String phaseId,
    String sessionId,
    String attendanceId,
  ) async {
    final doc = await _attendanceCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(attendanceId).get();

    if (!doc.exists) return null;

    return AttendanceModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }

  Stream<List<AttendanceModel>> getMyAttendance(String traineeId) {
  return FirebaseFirestore.instance
      .collectionGroup('attendance')
      .where('traineeId', isEqualTo: traineeId)
      .orderBy('markedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
            .toList(),
      );
}

  /// Stream single attendance record
  Stream<AttendanceModel?> getAttendanceRecordStream(
    String programmeId,
    String phaseId,
    String sessionId,
    String attendanceId,
  ) {
    return _attendanceCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(attendanceId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return AttendanceModel.fromMap(
        doc.data()!,
        doc.id,
      );
    });
  }

  /// Update Attendance
  Future<void> updateAttendance(
    AttendanceModel attendance,
  ) async {
    await _attendanceCollection(
      attendance.programmeId,
      attendance.phaseId,
      attendance.sessionId,
    ).doc(attendance.id).update(
          attendance.toMap(),
        );
  }

  /// Delete Attendance
  Future<void> deleteAttendance(
    String programmeId,
    String phaseId,
    String sessionId,
    String attendanceId,
  ) async {
    await _attendanceCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(attendanceId).delete();
  }
}