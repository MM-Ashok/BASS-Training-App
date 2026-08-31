import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Feedback collection reference
  CollectionReference<Map<String, dynamic>> _feedbackCollection(
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
        .collection('feedback');
  }

  /// Create Feedback
  Future<void> createFeedback(
    FeedbackModel feedback,
  ) async {
    await _feedbackCollection(
      feedback.programmeId,
      feedback.phaseId,
      feedback.sessionId,
    ).doc(feedback.id).set(
          feedback.toMap(),
        );
  }

  /// Get all feedback for a session
  Stream<List<FeedbackModel>> getFeedback(
    String programmeId,
    String phaseId,
    String sessionId,
  ) {
    return _feedbackCollection(
      programmeId,
      phaseId,
      sessionId,
    )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FeedbackModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get single feedback
  Future<FeedbackModel?> getFeedbackRecord(
    String programmeId,
    String phaseId,
    String sessionId,
    String feedbackId,
  ) async {
    final doc = await _feedbackCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(feedbackId).get();

    if (!doc.exists) return null;

    return FeedbackModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }

  /// Stream single feedback
  Stream<FeedbackModel?> getFeedbackRecordStream(
    String programmeId,
    String phaseId,
    String sessionId,
    String feedbackId,
  ) {
    return _feedbackCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(feedbackId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return FeedbackModel.fromMap(
        doc.data()!,
        doc.id,
      );
    });
  }

  /// Update feedback
  Future<void> updateFeedback(
    FeedbackModel feedback,
  ) async {
    await _feedbackCollection(
      feedback.programmeId,
      feedback.phaseId,
      feedback.sessionId,
    ).doc(feedback.id).update(
          feedback.toMap(),
        );
  }

  /// Delete feedback
  Future<void> deleteFeedback(
    String programmeId,
    String phaseId,
    String sessionId,
    String feedbackId,
  ) async {
    await _feedbackCollection(
      programmeId,
      phaseId,
      sessionId,
    ).doc(feedbackId).delete();
  }
}