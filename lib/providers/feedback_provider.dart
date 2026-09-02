import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();
  final _uuid = const Uuid();
  String? _organisationId;

  List<FeedbackEntry> sessionEntries = [];
  List<FeedbackEntry> traineeEntries = [];
  List<SkillTag> skillTags = [];

  StreamSubscription? _sessionSub;
  StreamSubscription? _traineeSub;
  StreamSubscription? _tagsSub;

  void init(String organisationId) {
    _organisationId = organisationId;
    _tagsSub?.cancel();
    _tagsSub = _service.watchSkillTags(organisationId).listen((data) {
      skillTags = data;
      // Seed a starter set once, first time an org has none — makes the
      // screen usable out of the box instead of an empty tag picker.
      if (data.isEmpty) _seedDefaultSkillTags(organisationId);
      notifyListeners();
    });
  }

  Future<void> _seedDefaultSkillTags(String orgId) async {
    const defaults = [
      ['Edge Control', 'Technical'],
      ['Turn Shape', 'Technical'],
      ['Client Communication', 'Teaching'],
      ['Lesson Planning', 'Teaching'],
      ['Terrain Selection', 'Safety'],
      ['Group Management', 'Teaching'],
    ];
    for (final d in defaults) {
      await _service.createSkillTag(orgId, SkillTag(id: '', name: d[0], category: d[1]));
    }
  }

  void watchSession(String programmeId, String sessionId) {
    if (_organisationId == null) return;
    _sessionSub?.cancel();
    _sessionSub =
        _service.watchForSession(_organisationId!, programmeId, sessionId).listen((data) {
      sessionEntries = data;
      notifyListeners();
    });
  }

  void watchTrainee(String traineeId, {String? skillTagId}) {
    if (_organisationId == null) return;
    _traineeSub?.cancel();
    _traineeSub = _service
        .watchForTraineeBySkill(_organisationId!, traineeId, skillTagId: skillTagId)
        .listen((data) {
      traineeEntries = data;
      notifyListeners();
    });
  }

  Future<void> addEntry({
    required String programmeId,
    required String sessionId,
    required String traineeId,
    required String authorId,
    required FeedbackAuthorType authorType,
    required String content,
    List<String> skillTagIds = const [],
    int? rating,
    bool isVoiceTranscribed = false,
  }) async {
    if (_organisationId == null) return;
    final entry = FeedbackEntry(
      id: _uuid.v4(),
      sessionId: sessionId,
      traineeId: traineeId,
      authorId: authorId,
      authorType: authorType,
      content: content,
      skillTagIds: skillTagIds,
      ratingOutOfFive: rating,
      isVoiceTranscribed: isVoiceTranscribed,
      createdAt: DateTime.now(),
    );
    await _service.createEntry(_organisationId!, programmeId, entry);
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _traineeSub?.cancel();
    _tagsSub?.cancel();
    super.dispose();
  }
}
