import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/ski_hours_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_export_service.dart';
import '../../services/pace_calculation_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Generates and shares the end-of-season PDF/XLSX report for the
/// current trainee, pulling live data from the ski hours, task, and
/// attendance providers rather than placeholder numbers.
class SeasonReportScreen extends StatefulWidget {
  const SeasonReportScreen({super.key});

  @override
  State<SeasonReportScreen> createState() => _SeasonReportScreenState();
}

class _SeasonReportScreenState extends State<SeasonReportScreen> {
  bool _generating = false;

  // Placeholder programme window — see SkiHoursTrackerScreen note; wire
  // to the trainee's actual assigned programme dates once available.
  final DateTime _programmeStart = DateTime.now().subtract(const Duration(days: 60));
  final DateTime _programmeEnd = DateTime.now().add(const Duration(days: 90));

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    if (auth.currentUser != null) {
      context.read<SkiHoursProvider>().watchForTrainee(orgId, auth.currentUser!.id);
      context.read<TaskProvider>()
        ..init(orgId)
        ..watchTraineeCompletions(auth.currentUser!.id);
      context.read<AttendanceProvider>()
        ..init(orgId)
        ..watchTrainee(auth.currentUser!.id);
    }
  }

  Future<void> _generate(bool asPdf) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _generating = true);

    final skiHours = context.read<SkiHoursProvider>().entries;
    final taskCompletions = context.read<TaskProvider>().myCompletions;
    final attendance = context.read<AttendanceProvider>().traineeRecords;
    final pace = PaceCalculationService.calculatePace(
      entries: skiHours,
      programmeStart: _programmeStart,
      programmeEnd: _programmeEnd,
    );

    try {
      final path = asPdf
          ? await ReportExportService.generatePdfReport(
              trainee: user,
              programmeTitle: 'Current Programme',
              skiHours: skiHours,
              taskCompletions: taskCompletions,
              attendance: attendance,
              paceResult: pace,
            )
          : await ReportExportService.generateXlsxReport(
              trainee: user,
              programmeTitle: 'Current Programme',
              skiHours: skiHours,
              taskCompletions: taskCompletions,
              paceResult: pace,
            );

      if (!mounted) return;
      await Share.shareXFiles([XFile(path)], text: 'Season Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not generate report: $e')));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skiHours = context.watch<SkiHoursProvider>().entries;
    final pace = PaceCalculationService.calculatePace(
      entries: skiHours,
      programmeStart: _programmeStart,
      programmeEnd: _programmeEnd,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Season Report')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Preview', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _StatRow(
                      label: 'Weighted hours',
                      value:
                          '${pace.actualWeightedHours.toStringAsFixed(1)} / ${PaceCalculationService.targetHours.toStringAsFixed(0)}',
                    ),
                    _StatRow(label: 'Pace status', value: pace.status.label),
                    _StatRow(
                        label: 'Progress',
                        value: '${(pace.progressFraction * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generating ? null : () => _generate(true),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Generate & Share PDF'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _generating ? null : () => _generate(false),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Generate & Share XLSX'),
            ),
            if (_generating) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
        ],
      ),
    );
  }
}
