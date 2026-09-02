import 'package:flutter/material.dart';
import '../../widgets/role_dashboard_scaffold.dart';
import '../../utils/theme.dart';
import '../coach/programme_builder/programme_list_screen.dart';
import '../shared/task_library_screen.dart';
import '../shared/pending_reviews_screen.dart';
import '../shared/messaging_screen.dart';
import '../shared/season_report_screen.dart';
import '../shared/session_picker_screen.dart';
import 'squad_engagement_screen.dart';

/// Head Coach: owns programme oversight across their coaching team,
/// reviews coach-submitted task approvals, monitors squad-wide
/// engagement/attendance metrics.
class HeadCoachDashboard extends StatelessWidget {
  const HeadCoachDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      roleLabel: 'Head Coach',
      tiles: [
        DashboardTile(
          title: 'My Programmes',
          icon: Icons.calendar_view_month,
          color: AppTheme.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProgrammeListScreen()),
          ),
        ),
        DashboardTile(
          title: 'Pending Reviews',
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
          title: 'Squad Engagement',
          icon: Icons.insights_outlined,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SquadEngagementScreen()),
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
          title: 'Team Messaging',
          icon: Icons.forum_outlined,
          color: Colors.teal,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MessagingScreen()),
          ),
        ),
        DashboardTile(
          title: 'Season Reports',
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