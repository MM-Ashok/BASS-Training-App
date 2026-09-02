import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../services/firestore_paths.dart';
import '../main.dart' show offlineService;
import '../services/offline_service.dart';

/// Attendance provider — deliberately routes writes through
/// [OfflineService]'s outbox queue rather than straight to Firestore, as
/// the reference implementation of the offline-write pattern described
/// in the README. Reads still rely on Firestore's own offline cache.
class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  String? _organisationId;

  List<AttendanceRecord> sessionRecords = [];
  List<AttendanceRecord> traineeRecords = [];

  StreamSubscription? _sessionSub;
  StreamSubscription? _traineeSub;

  void init(String organisationId) {
    _organisationId = organisationId;
  }

  void watchSession(String programmeId, String sessionId) {
    if (_organisationId == null) return;
    _sessionSub?.cancel();
    _sessionSub = _service.watchForSession(_organisationId!, programmeId, sessionId).listen((data) {
      sessionRecords = data;
      notifyListeners();
    });
  }

  void watchTrainee(String traineeId) {
    if (_organisationId == null) return;
    _traineeSub?.cancel();
    _traineeSub = _service.watchForTrainee(_organisationId!, traineeId).listen((data) {
      traineeRecords = data;
      notifyListeners();
    });
  }

  Future<void> markAttendance({
    required String programmeId,
    required String sessionId,
    required String traineeId,
    required AttendanceStatus status,
    required String coachId,
  }) async {
    if (_organisationId == null) return;
    final record = AttendanceRecord(
      id: '${sessionId}_$traineeId',
      sessionId: sessionId,
      traineeId: traineeId,
      status: status,
      checkInTime: status == AttendanceStatus.present ? DateTime.now() : null,
      recordedByCoachId: coachId,
      createdAt: DateTime.now(),
    );

    final online = await offlineService.isOnline();
    if (online) {
      await _service.markAttendance(_organisationId!, programmeId, record);
    } else {
      // Queue for replay once signal returns — this is the offline
      // pattern in action for mountain use with poor connectivity.
      await offlineService.queueWrite(PendingWrite(
        collectionPath: FirestorePaths.attendance(_organisationId!, programmeId, sessionId),
        docId: record.id,
        data: record.toMap(),
        operation: PendingWriteOp.update,
        queuedAt: DateTime.now(),
      ));
      // Optimistically reflect the change locally so the coach sees it
      // marked even before sync completes.
      sessionRecords = [
        ...sessionRecords.where((r) => r.traineeId != traineeId),
        record,
      ];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _traineeSub?.cancel();
    super.dispose();
  }
}
