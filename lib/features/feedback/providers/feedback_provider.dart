import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/feedback_model.dart';
import '../services/feedback_service.dart';

/// Service Provider
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService();
});

/// Parameters for Feedback List
class FeedbackParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;

  const FeedbackParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackParams &&
          runtimeType == other.runtimeType &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId;

  @override
  int get hashCode =>
      Object.hash(programmeId, phaseId, sessionId);
}

/// Stream all feedback for a session
final feedbackProvider =
    StreamProvider.family<List<FeedbackModel>, FeedbackParams>(
  (ref, params) {
    return ref.read(feedbackServiceProvider).getFeedback(
          params.programmeId,
          params.phaseId,
          params.sessionId,
        );
  },
);

/// Parameters for Single Feedback
class FeedbackRecordParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;
  final String feedbackId;

  const FeedbackRecordParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
    required this.feedbackId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackRecordParams &&
          runtimeType == other.runtimeType &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId &&
          feedbackId == other.feedbackId;

  @override
  int get hashCode => Object.hash(
        programmeId,
        phaseId,
        sessionId,
        feedbackId,
      );
}

/// Stream single feedback record
final feedbackRecordProvider =
    StreamProvider.family<FeedbackModel?, FeedbackRecordParams>(
  (ref, params) {
    return ref.read(feedbackServiceProvider).getFeedbackRecordStream(
          params.programmeId,
          params.phaseId,
          params.sessionId,
          params.feedbackId,
        );
  },
);