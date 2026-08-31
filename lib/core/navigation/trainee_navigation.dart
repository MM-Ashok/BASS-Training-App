import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';

import '../../features/dashboard/screens/trainee_dashboard.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class TraineeNavigation extends StatefulWidget {
  const TraineeNavigation({super.key});

  @override
  State<TraineeNavigation> createState() =>
      _TraineeNavigationState();
}

class _TraineeNavigationState
    extends State<TraineeNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const TraineeDashboard(),

    // Messages
    const ConversationsScreen(),


    // Experience (placeholder for now)
    const Scaffold(
      body: Center(
        child: Text("My Experience"),
      ),
    ),

    // Profile (placeholder)
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
        role: UserRole.trainee,
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