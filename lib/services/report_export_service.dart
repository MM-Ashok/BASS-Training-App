import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/ski_hours_model.dart';
import '../models/task_model.dart';
import '../models/attendance_model.dart';
import 'pace_calculation_service.dart';

/// Generates the end-of-season PDF and XLSX reports for a trainee.
/// Both formats pull from the same summary data so figures always match
/// between the two exports.
class ReportExportService {
  /// Builds and saves a PDF season report, returns the local file path.
  static Future<String> generatePdfReport({
    required AppUser trainee,
    required String programmeTitle,
    required List<SkiHoursEntry> skiHours,
    required List<TaskCompletion> taskCompletions,
    required List<AttendanceRecord> attendance,
    required PaceResult paceResult,
  }) async {
    final doc = pw.Document();

    final approvedTasks =
        taskCompletions.where((t) => t.status == TaskCompletionStatus.approved).length;
    final attendanceRate = attendance.isEmpty
        ? 0.0
        : attendance.where((a) => a.status == AttendanceStatus.present).length /
            attendance.length;

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'End of Season Report'),
          pw.Text('Trainee: ${trainee.displayName}', style: const pw.TextStyle(fontSize: 14)),
          pw.Text('Programme: $programmeTitle'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Ski School Experience (70-hour target)'),
          pw.Bullet(
              text:
                  'Weighted hours logged: ${paceResult.actualWeightedHours.toStringAsFixed(1)} / ${PaceCalculationService.targetHours}'),
          pw.Bullet(text: 'Pace status: ${paceResult.status.label}'),
          pw.Bullet(
              text:
                  'Progress: ${(paceResult.progressFraction * 100).toStringAsFixed(0)}%'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Task Completion'),
          pw.Bullet(text: 'Approved tasks: $approvedTasks / ${taskCompletions.length}'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Attendance'),
          pw.Bullet(text: 'Attendance rate: ${(attendanceRate * 100).toStringAsFixed(0)}%'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Hours Breakdown by Activity'),
          ...PaceCalculationService.breakdownByActivity(skiHours).entries.map(
                (e) => pw.Bullet(text: '${e.key.label}: ${e.value.toStringAsFixed(1)} hrs'),
              ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/season_report_${trainee.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  /// Builds and saves an XLSX season report with a raw-data sheet
  /// (useful for head coaches auditing hours/tasks across the squad).
  static Future<String> generateXlsxReport({
    required AppUser trainee,
    required String programmeTitle,
    required List<SkiHoursEntry> skiHours,
    required List<TaskCompletion> taskCompletions,
    required PaceResult paceResult,
  }) async {
    final excel = Excel.createExcel();

    final summarySheet = excel['Summary'];
    summarySheet.appendRow([TextCellValue('Trainee'), TextCellValue(trainee.displayName)]);
    summarySheet.appendRow([TextCellValue('Programme'), TextCellValue(programmeTitle)]);
    summarySheet.appendRow([
      TextCellValue('Weighted Hours'),
      DoubleCellValue(paceResult.actualWeightedHours),
    ]);
    summarySheet.appendRow([TextCellValue('Target Hours'), DoubleCellValue(PaceCalculationService.targetHours)]);
    summarySheet.appendRow([TextCellValue('Pace Status'), TextCellValue(paceResult.status.label)]);

    final hoursSheet = excel['Ski Hours Log'];
    hoursSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Activity Type'),
      TextCellValue('Raw Hours'),
      TextCellValue('Weight'),
      TextCellValue('Weighted Hours'),
      TextCellValue('Coach Verified'),
    ]);
    for (final entry in skiHours) {
      hoursSheet.appendRow([
        TextCellValue(entry.date.toIso8601String().split('T').first),
        TextCellValue(entry.activityType.label),
        DoubleCellValue(entry.rawHours),
        DoubleCellValue(entry.activityType.weight),
        DoubleCellValue(entry.weightedHours),
        TextCellValue(entry.coachVerified ? 'Yes' : 'No'),
      ]);
    }

    final tasksSheet = excel['Task Completions'];
    tasksSheet.appendRow([
      TextCellValue('Task ID'),
      TextCellValue('Status'),
      TextCellValue('Submitted At'),
      TextCellValue('Reviewed At'),
    ]);
    for (final t in taskCompletions) {
      tasksSheet.appendRow([
        TextCellValue(t.taskDefinitionId),
        TextCellValue(t.status.name),
        TextCellValue(t.submittedAt.toIso8601String()),
        TextCellValue(t.reviewedAt?.toIso8601String() ?? ''),
      ]);
    }

    excel.delete('Sheet1');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/season_report_${trainee.id}.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file.path;
  }
}
