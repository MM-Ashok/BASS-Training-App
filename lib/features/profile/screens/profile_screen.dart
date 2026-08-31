import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/authentication/screens/login_screen.dart';

import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_tile.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (user) {
          if (user == null) {
            return const Center(
              child: Text("Profile not found"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ProfileHeader(
                user: user,
              ),

              const SizedBox(height: 24),

              ProfileInfoCard(
                icon: Icons.email,
                title: "Email",
                value: user.email,
              ),

              ProfileInfoCard(
                icon: Icons.phone,
                title: "Phone",
                value: user.phone,
              ),

              ProfileInfoCard(
                icon: Icons.person,
                title: "Gender",
                value: user.gender,
              ),

              ProfileInfoCard(
                icon: Icons.cake,
                title: "Date of Birth",
                value: user.dob == null
                    ? ""
                    : "${user.dob!.day}/${user.dob!.month}/${user.dob!.year}",
              ),

              ProfileInfoCard(
                icon: Icons.badge,
                title: "Role",
                value: user.role,
              ),

              ProfileInfoCard(
                icon: Icons.school,
                title: "Programme",
                value: user.programmeId,
              ),

              const SizedBox(height: 25),

              ProfileMenuTile(
                icon: Icons.edit,
                title: "Edit Profile",
                subtitle: "Update your personal information",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        user: user,
                      ),
                    ),
                  );
                },
              ),

              ProfileMenuTile(
                icon: Icons.lock,
                title: "Change Password",
                subtitle: "Update your password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              ProfileMenuTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                textColor: Colors.red,
                title: "Logout",
                subtitle: "Sign out from BASS Training",
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text(
                        "Are you sure you want to logout?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  await ref
                      .read(profileControllerProvider)
                      .logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}