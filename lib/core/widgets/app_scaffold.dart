import 'package:flutter/material.dart';

import '../widgets/app_appbar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final UserRole role;
  final Widget body;

  final Widget? drawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  final bool showProfile;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.title,
    required this.role,
    required this.body,
    this.drawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showProfile = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppAppBar(
        title: title,
        role: role,
        showProfile: showProfile,
      ),

      drawer: drawer,

      body: SafeArea(
        child: body,
      ),

      floatingActionButton: floatingActionButton,

      bottomNavigationBar: bottomNavigationBar,
    );
  }
}