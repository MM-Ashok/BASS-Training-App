import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/ski_hours_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ski_hours_model.dart';
import '../../services/pace_calculation_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class SkiHoursTrackerScreen extends StatefulWidget {
  const SkiHoursTrackerScreen({super.key});

  @override
  State<SkiHoursTrackerScreen> createState() => _SkiHoursTrackerScreenState();
}

class _SkiHoursTrackerScreenState extends State<SkiHoursTrackerScreen> {
  // Placeholder programme window until wired to the trainee's actual
  // assigned programme dates via ProgrammeProvider.
  final DateTime _programmeStart = DateTime.now().subtract(const Duration(days: 60));
  final DateTime _programmeEnd = DateTime.now().add(const Duration(days: 90));

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    if (auth.currentUser != null) {
      final provider = context.read<SkiHoursProvider>();
      provider.watchForTrainee(orgId, auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SkiHoursProvider>();
    final pace = PaceCalculationService.calculatePace(
      entries: provider.entries,
      programmeStart: _programmeStart,
      programmeEnd: _programmeEnd,
    );
    final breakdown = PaceCalculationService.breakdownByActivity(provider.entries);

    return Scaffold(
      appBar: AppBar(title: const Text('70-Hour Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogHoursSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Hours'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PaceSummaryCard(pace: pace),
          const SizedBox(height: 16),
          _BreakdownChart(breakdown: breakdown),
          const SizedBox(height: 16),
          Text('Recent Entries', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (provider.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No hours logged yet', style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ...provider.entries.take(20).map((e) => _HoursEntryTile(entry: e)),
        ],
      ),
    );
  }

  void _showLogHoursSheet(BuildContext context) {
    final hoursController = TextEditingController();
    final noteController = TextEditingController();
    SkiActivityType type = SkiActivityType.leadTeaching;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log Ski Hours', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Hours'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SkiActivityType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Activity Type'),
                items: SkiActivityType.values
                    .map((a) => DropdownMenuItem(
                        value: a, child: Text('${a.label} (${(a.weight * 100).toInt()}% weight)')))
                    .toList(),
                onChanged: (v) => setSheetState(() => type = v ?? type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final hours = double.tryParse(hoursController.text);
                  if (hours == null || hours <= 0) return;
                  await context.read<SkiHoursProvider>().logHours(
                        rawHours: hours,
                        activityType: type,
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaceSummaryCard extends StatelessWidget {
  final PaceResult pace;
  const _PaceSummaryCard({required this.pace});

  @override
  Widget build(BuildContext context) {
    final color = StatusColors.forPaceStatus(pace.status.label);
    return Card(
      color: color.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: color),
                const SizedBox(width: 8),
                Text(pace.status.label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pace.progressFraction,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${pace.actualWeightedHours.toStringAsFixed(1)} / '
              '${PaceCalculationService.targetHours.toStringAsFixed(0)} weighted hours',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Expected by now: ${pace.expectedWeightedHours.toStringAsFixed(1)} hrs · '
              '${pace.deltaHours >= 0 ? '+' : ''}${pace.deltaHours.toStringAsFixed(1)} hrs vs pace',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            if (pace.status != PaceStatus.complete) ...[
              const SizedBox(height: 4),
              Text(
                'Need ~${pace.requiredWeeklyPaceHours.toStringAsFixed(1)} weighted hrs/week to finish on time',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownChart extends StatelessWidget {
  final Map<SkiActivityType, double> breakdown;
  const _BreakdownChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final entries = breakdown.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = [
      AppTheme.primary,
      AppTheme.accent,
      AppTheme.success,
      AppTheme.warning,
      Colors.purple,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hours by Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        title: '${entries[i].value.toStringAsFixed(0)}h',
                        color: colors[i % colors.length],
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: colors[i % colors.length]),
                      const SizedBox(width: 4),
                      Text(entries[i].key.label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoursEntryTile extends StatelessWidget {
  final SkiHoursEntry entry;
  const _HoursEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(entry.rawHours.toStringAsFixed(0),
              style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
        ),
        title: Text(entry.activityType.label),
        subtitle: Text(
          '${dateFmt.format(entry.date)} · ${entry.weightedHours.toStringAsFixed(1)} weighted hrs'
          '${entry.note != null ? "\n${entry.note}" : ""}',
        ),
        isThreeLine: entry.note != null,
        trailing: entry.coachVerified
            ? const Icon(Icons.verified, color: AppTheme.success, size: 20)
            : const Icon(Icons.schedule, color: Colors.grey, size: 20),
      ),
    );
  }
}
