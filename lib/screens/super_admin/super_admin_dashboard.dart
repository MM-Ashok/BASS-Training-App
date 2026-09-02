import 'package:flutter/material.dart';
import '../../widgets/role_dashboard_scaffold.dart';
import '../../utils/theme.dart';
import '../coach/programme_builder/programme_list_screen.dart';
import '../shared/task_library_screen.dart';
import '../shared/messaging_screen.dart';
import '../shared/season_report_screen.dart';
import 'branding_settings_screen.dart';
import 'user_management_screen.dart';

/// Super Admin: full org control — org settings, all programmes, user
/// management across roles, white-label branding config.
class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      roleLabel: 'Super Admin',
      tiles: [
        DashboardTile(
          title: 'All Programmes',
          icon: Icons.calendar_view_month,
          color: AppTheme.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProgrammeListScreen()),
          ),
        ),
        DashboardTile(
          title: 'User Management',
          icon: Icons.manage_accounts,
          color: AppTheme.accent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
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
          title: 'Org & White-Label Settings',
          icon: Icons.settings_suggest,
          color: Colors.deepPurple,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BrandingSettingsScreen()),
          ),
        ),
        DashboardTile(
          title: 'Messaging',
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