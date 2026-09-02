import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/attendance_model.dart';
import '../../models/task_model.dart';
import '../../models/feedback_model.dart';
import '../../services/engagement_service.dart';
import '../../services/firestore_paths.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Squad-wide engagement view for Head Coach / Coach — computes each
/// trainee's composite score live from Firestore via [EngagementService],
/// rather than showing static/placeholder numbers.
class SquadEngagementScreen extends StatefulWidget {
  const SquadEngagementScreen({super.key});

  @override
  State<SquadEngagementScreen> createState() => _SquadEngagementScreenState();
}

class _SquadEngagementScreenState extends State<SquadEngagementScreen> {
  List<EngagementSummary>? _summaries;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final orgId =
        context.read<AuthProvider>().currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final db = FirebaseFirestore.instance;

    // Pull every trainee in the org, then compute each one's engagement
    // score from their attendance/task/feedback records.
    final usersSnap = await db
        .collection(FirestorePaths.users(orgId))
        .where('role', isEqualTo: 'trainee')
        .get();

    final summaries = <EngagementSummary>[];
    for (final userDoc in usersSnap.docs) {
      final traineeId = userDoc.id;

      final attendanceSnap = await db
          .collectionGroup('attendance')
          .where('traineeId', isEqualTo: traineeId)
          .get();
      final attendance =
          attendanceSnap.docs.map((d) => AttendanceRecord.fromMap(d.id, d.data())).toList();

      final completionsSnap = await db
          .collection(FirestorePaths.taskCompletions(orgId))
          .where('traineeId', isEqualTo: traineeId)
          .get();
      final completions =
          completionsSnap.docs.map((d) => TaskCompletion.fromMap(d.id, d.data())).toList();

      final feedbackSnap = await db
          .collectionGroup('feedbackEntries')
          .where('traineeId', isEqualTo: traineeId)
          .get();
      final feedback =
          feedbackSnap.docs.map((d) => FeedbackEntry.fromMap(d.id, d.data())).toList();

      summaries.add(EngagementService.calculate(
        traineeId: traineeId,
        attendanceRecords: attendance,
        taskCompletions: completions,
        feedbackEntries: feedback,
      ));
    }

    summaries.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));

    if (mounted) {
      setState(() {
        _summaries = summaries;
        _loading = false;
      });
    }
  }

  Color _scoreColor(double score) {
    if (score >= 75) return AppTheme.success;
    if (score >= 50) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squad Engagement'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            setState(() => _loading = true);
            _load();
          }),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_summaries == null || _summaries!.isEmpty)
              ? Center(
                  child: Text('No trainees found in this organisation yet',
                      style: TextStyle(color: Colors.grey[600])))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _summaries!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = _summaries![i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(s.traineeId,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _scoreColor(s.engagementScore).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    s.engagementScore.toStringAsFixed(0),
                                    style: TextStyle(
                                        color: _scoreColor(s.engagementScore),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _MetricBar(label: 'Attendance', value: s.attendanceRate),
                            _MetricBar(label: 'Task completion', value: s.taskCompletionRate),
                            const SizedBox(height: 4),
                            Text(
                              s.avgCoachResponseHours > 0
                                  ? 'Avg. coach response time: ${s.avgCoachResponseHours.toStringAsFixed(1)}h'
                                  : 'No reviewed tasks yet to measure response time',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final double value;
  const _MetricBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(value * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
