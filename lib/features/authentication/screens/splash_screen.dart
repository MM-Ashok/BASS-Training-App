import 'package:flutter/material.dart';
import 'login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/app_user.dart';
import '../services/user_service.dart';

import '../../dashboard/screens/super_admin_dashboard.dart';
import '../../dashboard/screens/head_coach_dashboard.dart';
import '../../dashboard/screens/coach_dashboard.dart';
import '../../dashboard/screens/trainee_dashboard.dart';

import '../../../core/navigation/super_admin_navigation.dart';
import '../../../core/navigation/head_coach_navigation.dart';
import '../../../core/navigation/coach_navigation.dart';
import '../../../core/navigation/trainee_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkLogin();
    super.initState();

    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   );
    // });
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // No user logged in
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // User already logged in
    final AppUser? appUser = await UserService().getCurrentUser();

    if (!mounted) return;

    if (appUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    Widget dashboard;

    switch (appUser.role) {
      case 'superAdmin':
        // dashboard = const SuperAdminDashboard();
         dashboard = const SuperAdminNavigation();
        break;

      case 'headCoach':
        // dashboard = const HeadCoachDashboard();
        dashboard = const HeadCoachNavigation();
        break;

      case 'coach':
        // dashboard = const CoachDashboard();
         dashboard = const CoachNavigation();
        break;

      case 'trainee':
        // dashboard = const TraineeDashboard();
         dashboard = const TraineeNavigation();
        break;

      default:
        dashboard = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: FlutterLogo(size: 120)));
  }
}
