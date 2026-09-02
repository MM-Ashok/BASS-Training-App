import 'package:flutter/material.dart';
import '../../widgets/role_dashboard_scaffold.dart';
import '../../utils/theme.dart';
import 'programme_builder/programme_list_screen.dart';
import '../shared/task_library_screen.dart';
import '../shared/pending_reviews_screen.dart';
import '../shared/messaging_screen.dart';
import '../shared/session_picker_screen.dart';

/// Coach: runs day-to-day sessions for their assigned trainees — session
/// scheduling, attendance, task review, feedback journal entries.
class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      roleLabel: 'Coach',
      tiles: [
        DashboardTile(
          title: 'My Programme',
          icon: Icons.calendar_view_month,
          color: AppTheme.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProgrammeListScreen()),
          ),
        ),
        DashboardTile(
          title: 'Task Reviews',
          icon: Icons.fact_check_outlined,
          color: AppTheme.accent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PendingReviewsScreen()),
          ),
        ),
        DashboardTile(
          title: 'Task Library',
          icon: Icons.checklist,
          color: AppTheme.success,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskLibraryScreen()),
          ),
        ),
        DashboardTile(
          title: 'Feedback Journal',
          icon: Icons.edit_note,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SessionPickerScreen(mode: SessionPickerMode.feedback),
            ),
          ),
        ),
        DashboardTile(
          title: 'Attendance',
          icon: Icons.fact_check,
          color: Colors.brown,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SessionPickerScreen(mode: SessionPickerMode.attendance),
            ),
          ),
        ),
        DashboardTile(
          title: 'Messages',
          icon: Icons.forum_outlined,
          color: Colors.teal,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MessagingScreen()),
          ),
        ),
      ],
    );
  }
}
