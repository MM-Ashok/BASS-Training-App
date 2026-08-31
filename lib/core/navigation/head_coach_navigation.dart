import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';

import '../../features/dashboard/screens/head_coach_dashboard.dart';
import '../../features/users/screens/users_screen.dart';
import '../../features/programmes/screens/programmes_screen.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class HeadCoachNavigation extends StatefulWidget {
  const HeadCoachNavigation({super.key});

  @override
  State<HeadCoachNavigation> createState() =>
      _HeadCoachNavigationState();
}

class _HeadCoachNavigationState extends State<HeadCoachNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HeadCoachDashboard(),

    // Users
    const UsersScreen(),

    // Programmes
    const ProgrammesScreen(
      canEdit: true,
      canDelete: false,
    ),

    // Messages
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
        role: UserRole.headCoach,
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