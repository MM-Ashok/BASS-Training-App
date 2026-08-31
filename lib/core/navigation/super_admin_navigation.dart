import 'package:flutter/material.dart';

import '../../core/widgets/app_bottom_navigation.dart';

import '../../features/dashboard/screens/super_admin_dashboard.dart';
import '../../features/users/screens/users_screen.dart';
import '../../features/programmes/screens/programmes_screen.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class SuperAdminNavigation extends StatefulWidget {
  const SuperAdminNavigation({super.key});

  @override
  State<SuperAdminNavigation> createState() =>
      _SuperAdminNavigationState();
}

class _SuperAdminNavigationState
    extends State<SuperAdminNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const SuperAdminDashboard(),

    const UsersScreen(),

    const ProgrammesScreen(
      canEdit: true,
      canDelete: true,
    ),

    const ConversationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: AppBottomNavigation(
        role: UserRole.superAdmin,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}