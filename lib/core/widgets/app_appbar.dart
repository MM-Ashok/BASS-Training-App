import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/profile/screens/profile_screen.dart';

enum UserRole {
  superAdmin,
  headCoach,
  coach,
  trainee,
}

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showProfile;
  final UserRole role;
  final List<Widget>? actions;

  const AppAppBar({
    super.key,
    this.title,
    required this.role,
    this.showProfile = true,
    this.actions,
  });

  Color get backgroundColor {
    switch (role) {
      case UserRole.superAdmin:
        return const Color(0xFF0D47A1);

      case UserRole.headCoach:
        return Colors.green;

      case UserRole.coach:
        return Colors.deepPurple;

      case UserRole.trainee:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      title: Text(
        title ??
            user?.displayName ??
            user?.email?.split('@').first ??
            "",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,

        if (showProfile)
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}