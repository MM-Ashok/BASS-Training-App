import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';

import '../../features/dashboard/screens/coach_dashboard.dart';
import '../../features/programmes/screens/programmes_screen.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class CoachNavigation extends StatefulWidget {
  const CoachNavigation({super.key});

  @override
  State<CoachNavigation> createState() => _CoachNavigationState();
}

class _CoachNavigationState extends State<CoachNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const CoachDashboard(),

    const ProgrammesScreen(
      canEdit: false,
      canDelete: false,
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
        role: UserRole.coach,
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