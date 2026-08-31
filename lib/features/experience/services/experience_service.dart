import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/experience_model.dart';

class ExperienceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Experience collection for a trainee
  CollectionReference<Map<String, dynamic>> _experienceCollection(
    String traineeId,
  ) {
    return _firestore
        .collection('users')
        .doc(traineeId)
        .collection('experience');
  }

  /// Create Experience
  Future<void> createExperience(
    ExperienceModel experience,
  ) async {
    await _experienceCollection(
      experience.traineeId,
    ).doc(experience.id).set(
          experience.toMap(),
        );
  }

  /// Get all experience records for a trainee
  Stream<List<ExperienceModel>> getExperience(
    String traineeId,
  ) {
    return _experienceCollection(
      traineeId,
    )
        .orderBy(
          'date',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ExperienceModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get single experience record
  Future<ExperienceModel?> getExperienceRecord(
    String traineeId,
    String experienceId,
  ) async {
    final doc = await _experienceCollection(
      traineeId,
    ).doc(experienceId).get();

    if (!doc.exists) return null;

    return ExperienceModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }

  /// Stream single experience record
  Stream<ExperienceModel?> getExperienceRecordStream(
    String traineeId,
    String experienceId,
  ) {
    return _experienceCollection(
      traineeId,
    ).doc(experienceId).snapshots().map(
      (doc) {
        if (!doc.exists) return null;

        return ExperienceModel.fromMap(
          doc.data()!,
          doc.id,
        );
      },
    );
  }

  /// Update Experience
  Future<void> updateExperience(
    ExperienceModel experience,
  ) async {
    await _experienceCollection(
      experience.traineeId,
    ).doc(experience.id).update(
          experience.toMap(),
        );
  }

  /// Delete Experience
  Future<void> deleteExperience(
    String traineeId,
    String experienceId,
  ) async {
    await _experienceCollection(
      traineeId,
    ).doc(experienceId).delete();
  }

  /// Calculate total APPROVED hours
  Future<double> getApprovedHours(
    String traineeId,
  ) async {
    final snapshot = await _experienceCollection(
      traineeId,
    )
        .where(
          'status',
          isEqualTo: 'Approved',
        )
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final hours = (doc.data()['hours'] ?? 0).toDouble();
      total += hours;
    }

    return total;
  }

  /// Remaining hours (Target = 70)
  Future<double> getRemainingHours(
    String traineeId,
  ) async {
    final approved = await getApprovedHours(
      traineeId,
    );

    final remaining = 70 - approved;

    return remaining < 0 ? 0 : remaining;
  }

  /// Completion percentage
  Future<double> getCompletionPercentage(
    String traineeId,
  ) async {
    final approved = await getApprovedHours(
      traineeId,
    );

    return (approved / 70) * 100;
  }
}