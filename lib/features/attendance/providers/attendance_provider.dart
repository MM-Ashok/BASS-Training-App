import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/attendance_model.dart';
import '../services/attendance_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});



final myAttendanceProvider = StreamProvider<List<AttendanceModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return ref.read(attendanceServiceProvider).getMyAttendance(uid);
});

class AttendanceParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;

  const AttendanceParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceParams &&
          runtimeType == other.runtimeType &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId;

  @override
  int get hashCode => Object.hash(programmeId, phaseId, sessionId);
}

final attendanceProvider =
    StreamProvider.family<List<AttendanceModel>, AttendanceParams>((
      ref,
      params,
    ) {
      return ref
          .read(attendanceServiceProvider)
          .getAttendance(params.programmeId, params.phaseId, params.sessionId);
    });

class AttendanceRecordParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;
  final String attendanceId;

  const AttendanceRecordParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.attendanceId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordParams &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId &&
          attendanceId == other.attendanceId;

  @override
  int get hashCode =>
      Object.hash(programmeId, phaseId, sessionId, attendanceId);
}

final attendanceRecordProvider =
    StreamProvider.family<AttendanceModel?, AttendanceRecordParams>((
      ref,
      params,
    ) {
      return ref
          .read(attendanceServiceProvider)
          .getAttendanceRecordStream(
            params.programmeId,
            params.phaseId,
            params.sessionId,
            params.attendanceId,
          );
    });
