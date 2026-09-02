import '../models/attendance_model.dart';
import '../models/task_model.dart';
import '../models/feedback_model.dart';

/// Computes the composite engagement score shown on coach/head-coach
/// dashboards. Weights are intentionally simple and centralised here so
/// they can be tuned in one place once real season data is available.
class EngagementService {
  // Composite score weighting - tune these once real usage data exists.
  static const double _attendanceWeight = 0.4;
  static const double _taskCompletionWeight = 0.35;
  static const double _feedbackEngagementWeight = 0.25;

  static EngagementSummary calculate({
    required String traineeId,
    required List<AttendanceRecord> attendanceRecords,
    required List<TaskCompletion> taskCompletions,
    required List<FeedbackEntry> feedbackEntries,
  }) {
    final attendanceRate = attendanceRecords.isEmpty
        ? 0.0
        : attendanceRecords.where((a) => a.status == AttendanceStatus.present).length /
            attendanceRecords.length;

    final approvedOrAuto = taskCompletions.where((t) =>
        t.status == TaskCompletionStatus.approved || t.status == TaskCompletionStatus.submitted);
    final taskCompletionRate = taskCompletions.isEmpty
        ? 0.0
        : approvedOrAuto.length / taskCompletions.length;

    // Coach responsiveness: derived from real submittedAt -> reviewedAt
    // gaps on coach-reviewed task completions. Auto-verified tasks have
    // no coach in the loop so they're excluded from this metric.
    final reviewedWithGap = taskCompletions.where((t) => t.reviewedAt != null);
    double avgResponseHours = 0;
    int pairCount = 0;
    for (final t in reviewedWithGap) {
      avgResponseHours += t.reviewedAt!.difference(t.submittedAt).inMinutes / 60.0;
      pairCount++;
    }
    if (pairCount > 0) avgResponseHours /= pairCount;

    // Feedback engagement: how many entries relative to a reasonable
    // expectation of 1 per session logged (capped at 1.0).
    final feedbackFactor = (feedbackEntries.length / (attendanceRecords.length == 0
            ? 1
            : attendanceRecords.length))
        .clamp(0.0, 1.0);

    final composite = (attendanceRate * _attendanceWeight) +
        (taskCompletionRate * _taskCompletionWeight) +
        (feedbackFactor * _feedbackEngagementWeight);

    return EngagementSummary(
      traineeId: traineeId,
      attendanceRate: attendanceRate,
      taskCompletionRate: taskCompletionRate,
      avgCoachResponseHours: avgResponseHours,
      feedbackEntriesCount: feedbackEntries.length,
      engagementScore: (composite * 100).clamp(0, 100),
    );
  }
}
