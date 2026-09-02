import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ski_hours_model.dart';
import '../services/firestore_paths.dart';
import '../services/pace_calculation_service.dart';

class SkiHoursProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  String? _organisationId;
  String? _traineeId;

  List<SkiHoursEntry> entries = [];
  StreamSubscription? _sub;

  PaceResult? paceResult;

  void watchForTrainee(String organisationId, String traineeId) {
    _organisationId = organisationId;
    _traineeId = traineeId;
    _sub?.cancel();
    _sub = _db
        .collection(FirestorePaths.skiHoursEntries(organisationId))
        .where('traineeId', isEqualTo: traineeId)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      entries = snap.docs.map((d) => SkiHoursEntry.fromMap(d.id, d.data())).toList();
      notifyListeners();
    });
  }

  void recalculatePace({required DateTime programmeStart, required DateTime programmeEnd}) {
    paceResult = PaceCalculationService.calculatePace(
      entries: entries,
      programmeStart: programmeStart,
      programmeEnd: programmeEnd,
    );
    notifyListeners();
  }

  Future<void> logHours({
    required double rawHours,
    required SkiActivityType activityType,
    String? sessionId,
    String? note,
    DateTime? date,
  }) async {
    if (_organisationId == null || _traineeId == null) return;
    final entry = SkiHoursEntry(
      id: _uuid.v4(),
      traineeId: _traineeId!,
      sessionId: sessionId,
      date: date ?? DateTime.now(),
      rawHours: rawHours,
      activityType: activityType,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(FirestorePaths.skiHoursEntries(_organisationId!))
        .add(entry.toMap());
  }

  Future<void> verifyEntry(String entryId, String coachId) async {
    if (_organisationId == null) return;
    await _db
        .doc('${FirestorePaths.skiHoursEntries(_organisationId!)}/$entryId')
        .update({'coachVerified': true, 'verifiedByCoachId': coachId});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
