import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/programme_model.dart';
import '../models/session_model.dart';
import '../services/firestore_service.dart';

/// Drives the programme builder: programme -> phases -> sessions CRUD.
/// Screens subscribe to the exposed lists; this provider owns the
/// Firestore stream subscriptions and keeps them in sync.
class ProgrammeProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final _uuid = const Uuid();

  String? _organisationId;
  List<Programme> programmes = [];
  List<Phase> phases = [];
  List<TrainingSession> sessions = [];

  String? selectedProgrammeId;

  StreamSubscription? _programmesSub;
  StreamSubscription? _phasesSub;
  StreamSubscription? _sessionsSub;

  bool isLoading = false;

  void init(String organisationId) {
    _organisationId = organisationId;
    _programmesSub?.cancel();
    _programmesSub = _firestore.watchProgrammes(organisationId).listen((data) {
      programmes = data;
      notifyListeners();
    });
  }

  void selectProgramme(String programmeId) {
    selectedProgrammeId = programmeId;
    if (_organisationId == null) return;

    _phasesSub?.cancel();
    _phasesSub = _firestore.watchPhases(_organisationId!, programmeId).listen((data) {
      phases = data;
      notifyListeners();
    });

    _sessionsSub?.cancel();
    _sessionsSub = _firestore.watchSessions(_organisationId!, programmeId).listen((data) {
      sessions = data;
      notifyListeners();
    });

    notifyListeners();
  }

  // ---------------- Programme CRUD ----------------

  Future<void> createProgramme({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String headCoachId,
  }) async {
    if (_organisationId == null) return;
    final now = DateTime.now();
    final programme = Programme(
      id: _uuid.v4(),
      organisationId: _organisationId!,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      headCoachId: headCoachId,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.createProgramme(_organisationId!, programme);
  }

  Future<void> updateProgramme(Programme programme) async {
    if (_organisationId == null) return;
    await _firestore.updateProgramme(_organisationId!, programme);
  }

  Future<void> deleteProgramme(String programmeId) async {
    if (_organisationId == null) return;
    await _firestore.deleteProgramme(_organisationId!, programmeId);
  }

  // ---------------- Phase CRUD ----------------

  Future<void> createPhase({
    required String programmeId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_organisationId == null) return;
    final now = DateTime.now();
    final phase = Phase(
      id: _uuid.v4(),
      programmeId: programmeId,
      title: title,
      description: description,
      orderIndex: phases.length,
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.createPhase(_organisationId!, phase);
  }

  Future<void> updatePhase(Phase phase) async {
    if (_organisationId == null) return;
    await _firestore.updatePhase(_organisationId!, phase);
  }

  Future<void> deletePhase(String programmeId, String phaseId) async {
    if (_organisationId == null) return;
    await _firestore.deletePhase(_organisationId!, programmeId, phaseId);
  }

  Future<void> reorderPhases(List<Phase> reordered) async {
    if (_organisationId == null) return;
    for (var i = 0; i < reordered.length; i++) {
      await _firestore.updatePhase(_organisationId!, reordered[i].copyWith(orderIndex: i));
    }
  }

  // ---------------- Session CRUD ----------------

  Future<void> createSession({
    required String programmeId,
    required String phaseId,
    required String title,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required String leadCoachId,
  }) async {
    if (_organisationId == null) return;
    final now = DateTime.now();
    final session = TrainingSession(
      id: _uuid.v4(),
      programmeId: programmeId,
      phaseId: phaseId,
      title: title,
      location: location,
      startTime: startTime,
      endTime: endTime,
      leadCoachId: leadCoachId,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.createSession(_organisationId!, session);
  }

  Future<void> updateSession(TrainingSession session) async {
    if (_organisationId == null) return;
    await _firestore.updateSession(_organisationId!, session);
  }

  Future<void> deleteSession(String programmeId, String sessionId) async {
    if (_organisationId == null) return;
    await _firestore.deleteSession(_organisationId!, programmeId, sessionId);
  }

  List<TrainingSession> sessionsForPhase(String phaseId) =>
      sessions.where((s) => s.phaseId == phaseId).toList();

  @override
  void dispose() {
    _programmesSub?.cancel();
    _phasesSub?.cancel();
    _sessionsSub?.cancel();
    super.dispose();
  }
}
