import 'package:flutter/material.dart';
import '../../widgets/role_dashboard_scaffold.dart';
import '../../utils/theme.dart';
import 'ski_hours_tracker_screen.dart';
import '../shared/task_library_screen.dart';
import '../shared/trainee_feedback_history_screen.dart';
import '../shared/trainee_attendance_history_screen.dart';
import '../shared/messaging_screen.dart';
import '../shared/season_report_screen.dart';

/// Trainee: tracks their own 70-hour progress, completes tasks, views
/// their programme schedule and feedback history.
class TraineeDashboard extends StatelessWidget {
  const TraineeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      roleLabel: 'My Training',
      tiles: [
        DashboardTile(
          title: '70-Hour Tracker',
          icon: Icons.speed,
          color: AppTheme.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SkiHoursTrackerScreen()),
          ),
        ),
        DashboardTile(
          title: 'My Tasks',
          icon: Icons.checklist,
          color: AppTheme.accent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskLibraryScreen()),
          ),
        ),
        DashboardTile(
          title: 'My Attendance',
          icon: Icons.calendar_today_outlined,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TraineeAttendanceHistoryScreen()),
          ),
        ),
        DashboardTile(
          title: 'Feedback Journal',
          icon: Icons.edit_note,
          color: Colors.brown,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TraineeFeedbackHistoryScreen()),
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
        DashboardTile(
          title: 'My Season Report',
          icon: Icons.picture_as_pdf_outlined,
          color: AppTheme.warning,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SeasonReportScreen()),
          ),
        ),
      ],
    );
  }
}
