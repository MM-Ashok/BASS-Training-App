import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/attendance_model.dart';
import '../../models/programme_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Coach-facing attendance check-in for a session. Pass in the trainee
/// roster (programme.traineeIds) so the coach can mark each one without
/// needing a separate roster lookup screen.
class AttendanceScreen extends StatefulWidget {
  final Programme programme;
  final String sessionId;
  final String sessionTitle;

  const AttendanceScreen({
    super.key,
    required this.programme,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    final orgId =
        context.read<AuthProvider>().currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final provider = context.read<AttendanceProvider>();
    provider.init(orgId);
    provider.watchSession(widget.programme.id, widget.sessionId);
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
    final auth = context.watch<AuthProvider>();
    final roster = widget.programme.traineeIds.isEmpty
        ? ['demo-trainee-1', 'demo-trainee-2', 'demo-trainee-3'] // placeholder roster for the scaffold
        : widget.programme.traineeIds;

    return Scaffold(
      appBar: AppBar(title: Text('Attendance · ${widget.sessionTitle}')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: roster.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final traineeId = roster[i];
          final existing = provider.sessionRecords
              .where((r) => r.traineeId == traineeId)
              .toList();
          final currentStatus = existing.isNotEmpty ? existing.first.status : null;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(child: Text(traineeId.substring(0, 1).toUpperCase())),
                  const SizedBox(width: 12),
                  Expanded(child: Text(traineeId, overflow: TextOverflow.ellipsis)),
                  Wrap(
                    spacing: 6,
                    children: AttendanceStatus.values.map((status) {
                      final selected = currentStatus == status;
                      return ChoiceChip(
                        label: Text(status.name, style: const TextStyle(fontSize: 11)),
                        selected: selected,
                        selectedColor: _statusColor(status).withOpacity(0.25),
                        onSelected: (_) => provider.markAttendance(
                          programmeId: widget.programme.id,
                          sessionId: widget.sessionId,
                          traineeId: traineeId,
                          status: status,
                          coachId: auth.currentUser?.id ?? 'demo-coach',
                        ),
                      );
                    }).toList(),
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
