import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/attendance_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class TraineeAttendanceHistoryScreen extends StatefulWidget {
  const TraineeAttendanceHistoryScreen({super.key});

  @override
  State<TraineeAttendanceHistoryScreen> createState() => _TraineeAttendanceHistoryScreenState();
}

class _TraineeAttendanceHistoryScreenState extends State<TraineeAttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final provider = context.read<AttendanceProvider>();
    provider.init(orgId);
    if (auth.currentUser != null) provider.watchTrainee(auth.currentUser!.id);
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return AppTheme.success;
      case AttendanceStatus.late:
        return AppTheme.warning;
      case AttendanceStatus.absent:
        return AppTheme.danger;
      case AttendanceStatus.excused:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final records = provider.traineeRecords;
    final rate = records.isEmpty
        ? 0.0
        : records.where((r) => r.status == AttendanceStatus.present).length / records.length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.fact_check, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Text('${(rate * 100).toStringAsFixed(0)}% attendance rate',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? Center(child: Text('No attendance recorded yet', style: TextStyle(color: Colors.grey[600])))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = records[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(r.status).withOpacity(0.15),
                            child: Icon(Icons.circle, size: 10, color: _statusColor(r.status)),
                          ),
                          title: Text(r.status.name),
                          subtitle: Text('Session: ${r.sessionId}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
