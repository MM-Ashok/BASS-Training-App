import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/programme_model.dart';
import '../models/session_model.dart';
import '../models/task_model.dart';
import 'firestore_paths.dart';

/// Central data-access layer for programme builder: programmes, phases,
/// sessions and tasks. Screens/providers call through here rather than
/// touching FirebaseFirestore directly, so offline caching, retries and
/// the eventual Primio-generated backend can be swapped in behind this
/// interface without rewriting UI code.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Programmes ----------------

  Future<String> createProgramme(String orgId, Programme programme) async {
    final ref = await _db.collection(FirestorePaths.programmes(orgId)).add(programme.toMap());
    return ref.id;
  }

  Future<void> updateProgramme(String orgId, Programme programme) {
    return _db
        .doc(FirestorePaths.programme(orgId, programme.id))
        .update(programme.toMap());
  }

  Future<void> deleteProgramme(String orgId, String programmeId) {
    return _db.doc(FirestorePaths.programme(orgId, programmeId)).delete();
  }

  Stream<List<Programme>> watchProgrammes(String orgId) {
    return _db
        .collection(FirestorePaths.programmes(orgId))
        .where('isArchived', isEqualTo: false)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Programme.fromMap(d.id, d.data())).toList());
  }

  Future<Programme?> getProgramme(String orgId, String programmeId) async {
    final doc = await _db.doc(FirestorePaths.programme(orgId, programmeId)).get();
    if (!doc.exists) return null;
    return Programme.fromMap(doc.id, doc.data()!);
  }

  // ---------------- Phases ----------------

  Future<String> createPhase(String orgId, Phase phase) async {
    final ref = await _db
        .collection(FirestorePaths.phases(orgId, phase.programmeId))
        .add(phase.toMap());
    return ref.id;
  }

  Future<void> updatePhase(String orgId, Phase phase) {
    return _db
        .doc(FirestorePaths.phase(orgId, phase.programmeId, phase.id))
        .update(phase.toMap());
  }

  Future<void> deletePhase(String orgId, String programmeId, String phaseId) {
    return _db.doc(FirestorePaths.phase(orgId, programmeId, phaseId)).delete();
  }

  Stream<List<Phase>> watchPhases(String orgId, String programmeId) {
    return _db
        .collection(FirestorePaths.phases(orgId, programmeId))
        .orderBy('orderIndex')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Phase.fromMap(d.id, d.data())).toList());
  }

  // ---------------- Sessions ----------------

  Future<String> createSession(String orgId, TrainingSession session) async {
    final ref = await _db
        .collection(FirestorePaths.sessions(orgId, session.programmeId))
        .add(session.toMap());
    return ref.id;
  }

  Future<void> updateSession(String orgId, TrainingSession session) {
    return _db
        .doc(FirestorePaths.session(orgId, session.programmeId, session.id))
        .update(session.toMap());
  }

  Future<void> deleteSession(String orgId, String programmeId, String sessionId) {
    return _db.doc(FirestorePaths.session(orgId, programmeId, sessionId)).delete();
  }

  Stream<List<TrainingSession>> watchSessions(String orgId, String programmeId,
      {String? phaseId}) {
    Query<Map<String, dynamic>> q =
        _db.collection(FirestorePaths.sessions(orgId, programmeId));
    if (phaseId != null) {
      q = q.where('phaseId', isEqualTo: phaseId);
    }
    return q
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TrainingSession.fromMap(d.id, d.data())).toList());
  }

  // ---------------- Task library ----------------

  Future<String> createTaskDefinition(String orgId, TaskDefinition task) async {
    final ref = await _db.collection(FirestorePaths.taskDefinitions(orgId)).add(task.toMap());
    return ref.id;
  }

  Future<void> updateTaskDefinition(String orgId, TaskDefinition task) {
    return _db
        .doc('${FirestorePaths.taskDefinitions(orgId)}/${task.id}')
        .update(task.toMap());
  }

  Future<void> deleteTaskDefinition(String orgId, String taskId) {
    return _db.doc('${FirestorePaths.taskDefinitions(orgId)}/$taskId').delete();
  }

  Stream<List<TaskDefinition>> watchTaskLibrary(String orgId, {String? programmeId}) {
    Query<Map<String, dynamic>> q = _db.collection(FirestorePaths.taskDefinitions(orgId));
    if (programmeId != null) {
      q = q.where('programmeId', whereIn: [programmeId, null]);
    }
    return q
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskDefinition.fromMap(d.id, d.data())).toList());
  }

  // ---------------- Task completions ----------------

  Future<String> submitTaskCompletion(String orgId, TaskCompletion completion) async {
    final ref =
        await _db.collection(FirestorePaths.taskCompletions(orgId)).add(completion.toMap());
    return ref.id;
  }

  Future<void> reviewTaskCompletion(String orgId, TaskCompletion completion) {
    return _db
        .doc('${FirestorePaths.taskCompletions(orgId)}/${completion.id}')
        .update(completion.toMap());
  }

  Stream<List<TaskCompletion>> watchCompletionsForTrainee(String orgId, String traineeId) {
    return _db
        .collection(FirestorePaths.taskCompletions(orgId))
        .where('traineeId', isEqualTo: traineeId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskCompletion.fromMap(d.id, d.data())).toList());
  }

  Stream<List<TaskCompletion>> watchPendingReviews(String orgId) {
    return _db
        .collection(FirestorePaths.taskCompletions(orgId))
        .where('status', isEqualTo: 'submitted')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskCompletion.fromMap(d.id, d.data())).toList());
  }
}
