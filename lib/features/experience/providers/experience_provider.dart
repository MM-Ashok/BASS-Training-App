import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/experience_model.dart';
import '../services/experience_service.dart';

/// Experience Service
final experienceServiceProvider = Provider<ExperienceService>((ref) {
  return ExperienceService();
});

/// ======================================================
/// Experience List Parameters
/// ======================================================

class ExperienceParams {
  final String traineeId;

  const ExperienceParams({
    required this.traineeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceParams &&
          runtimeType == other.runtimeType &&
          traineeId == other.traineeId;

  @override
  int get hashCode => traineeId.hashCode;
}

/// ======================================================
/// Experience List
/// ======================================================

final experienceProvider = StreamProvider.family<
    List<ExperienceModel>,
    ExperienceParams>((ref, params) {
  return ref.read(experienceServiceProvider).getExperience(
        params.traineeId,
      );
});

/// ======================================================
/// Single Experience Parameters
/// ======================================================

class ExperienceRecordParams {
  final String traineeId;
  final String experienceId;

  const ExperienceRecordParams({
    required this.traineeId,
    required this.experienceId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceRecordParams &&
          runtimeType == other.runtimeType &&
          traineeId == other.traineeId &&
          experienceId == other.experienceId;

  @override
  int get hashCode =>
      Object.hash(traineeId, experienceId);
}

/// ======================================================
/// Single Experience
/// ======================================================

final experienceRecordProvider =
    StreamProvider.family<
        ExperienceModel?,
        ExperienceRecordParams>((ref, params) {
  return ref
      .read(experienceServiceProvider)
      .getExperienceRecordStream(
        params.traineeId,
        params.experienceId,
      );
});

/// ======================================================
/// Approved Hours
/// ======================================================

final approvedHoursProvider =
    FutureProvider.family<double, String>((ref, traineeId) {
  return ref
      .read(experienceServiceProvider)
      .getApprovedHours(traineeId);
});

/// ======================================================
/// Remaining Hours
/// ======================================================

final remainingHoursProvider =
    FutureProvider.family<double, String>((ref, traineeId) {
  return ref
      .read(experienceServiceProvider)
      .getRemainingHours(traineeId);
});

/// ======================================================
/// Completion Percentage
/// ======================================================

final completionPercentageProvider =
    FutureProvider.family<double, String>((ref, traineeId) {
  return ref
      .read(experienceServiceProvider)
      .getCompletionPercentage(traineeId);
});