import '../models/ski_hours_model.dart';

/// Core logic for the 70-hour Ski School Experience tracker.
///
/// "Weighted pace" means two things combine here:
///  1. Each logged hour is weighted by activity type (see SkiActivityType.weight)
///     before it counts towards the 70-hour target.
///  2. Pace is measured against a time-based target curve (hours you *should*
///     have logged by today, given the programme's start/end dates), not just
///     a flat percentage — so a trainee can be "on pace" at 20% through a
///     season with only 14 of 70 hours, and "behind pace" with 30 hours if
///     they're 80% through the season.
///
/// This is a pure/stateless calculator so it's easy to unit test and to
/// reuse in the end-of-season PDF/XLSX report generator.
class PaceCalculationService {
  static const double targetHours = 70.0;

  /// Sum of weighted hours from a list of entries.
  static double totalWeightedHours(List<SkiHoursEntry> entries) {
    return entries.fold(0.0, (sum, e) => sum + e.weightedHours);
  }

  /// Only counts entries a coach has verified — useful for a "verified vs
  /// self-reported" split in the UI and reports.
  static double verifiedWeightedHours(List<SkiHoursEntry> entries) {
    return entries
        .where((e) => e.coachVerified)
        .fold(0.0, (sum, e) => sum + e.weightedHours);
  }

  static double progressFraction(List<SkiHoursEntry> entries) {
    final total = totalWeightedHours(entries);
    return (total / targetHours).clamp(0.0, 1.0);
  }

  /// Expected weighted hours "by now" if a trainee progressed linearly
  /// across the programme's date range. Used to compute pace status.
  static double expectedHoursByDate({
    required DateTime programmeStart,
    required DateTime programmeEnd,
    required DateTime asOf,
  }) {
    final totalSpan = programmeEnd.difference(programmeStart).inMinutes;
    if (totalSpan <= 0) return 0;
    final elapsed = asOf.difference(programmeStart).inMinutes.clamp(0, totalSpan);
    final fractionElapsed = elapsed / totalSpan;
    return targetHours * fractionElapsed;
  }

  /// Compares actual weighted hours logged against the expected pace curve
  /// and returns a status + the surplus/deficit in hours.
  static PaceResult calculatePace({
    required List<SkiHoursEntry> entries,
    required DateTime programmeStart,
    required DateTime programmeEnd,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final actual = totalWeightedHours(entries);
    final expected = expectedHoursByDate(
      programmeStart: programmeStart,
      programmeEnd: programmeEnd,
      asOf: now,
    );
    final delta = actual - expected;

    // Tolerance band: within +/- 3 weighted hours of the pace curve counts as "on pace".
    // This avoids flagging trainees red/green on noise around session-to-session variance.
    const tolerance = 3.0;

    PaceStatus status;
    if (actual >= targetHours) {
      status = PaceStatus.complete;
    } else if (delta >= tolerance) {
      status = PaceStatus.ahead;
    } else if (delta <= -tolerance) {
      status = PaceStatus.behind;
    } else {
      status = PaceStatus.onPace;
    }

    // Required weighted hours/week for the remainder of the programme to
    // still hit 70 by end date — useful for "you need X hrs/week" messaging.
    final remainingHours = (targetHours - actual).clamp(0.0, targetHours);
    final remainingDays = programmeEnd.difference(now).inDays;
    final remainingWeeks = (remainingDays / 7).clamp(0.1, double.infinity);
    final requiredWeeklyPace = remainingHours / remainingWeeks;

    return PaceResult(
      actualWeightedHours: actual,
      expectedWeightedHours: expected,
      deltaHours: delta,
      status: status,
      requiredWeeklyPaceHours: requiredWeeklyPace,
      progressFraction: (actual / targetHours).clamp(0.0, 1.0),
    );
  }

  /// Breaks down total weighted hours by activity type — feeds pie/bar
  /// charts in the trainee dashboard and the end-of-season report.
  static Map<SkiActivityType, double> breakdownByActivity(List<SkiHoursEntry> entries) {
    final map = <SkiActivityType, double>{for (final t in SkiActivityType.values) t: 0.0};
    for (final e in entries) {
      map[e.activityType] = (map[e.activityType] ?? 0) + e.weightedHours;
    }
    return map;
  }
}

enum PaceStatus { ahead, onPace, behind, complete }

extension PaceStatusX on PaceStatus {
  String get label {
    switch (this) {
      case PaceStatus.ahead:
        return 'Ahead of pace';
      case PaceStatus.onPace:
        return 'On pace';
      case PaceStatus.behind:
        return 'Behind pace';
      case PaceStatus.complete:
        return '70 hours complete';
    }
  }
}

class PaceResult {
  final double actualWeightedHours;
  final double expectedWeightedHours;
  final double deltaHours;
  final PaceStatus status;
  final double requiredWeeklyPaceHours;
  final double progressFraction;

  PaceResult({
    required this.actualWeightedHours,
    required this.expectedWeightedHours,
    required this.deltaHours,
    required this.status,
    required this.requiredWeeklyPaceHours,
    required this.progressFraction,
  });
}
