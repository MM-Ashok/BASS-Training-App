import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../features/authentication/providers/user_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  final String uid;

  const UserDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (user) {
          if (user == null) {
            return const Center(child: Text("User not found"));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(user.email),

                const SizedBox(height: 20),

                _infoCard("Role", user.role),
                _infoCard(
                  "Programme ID",
                  user.programmeId.isEmpty ? "Not Assigned" : user.programmeId,
                ),

                const SizedBox(height: 20),

                SwitchListTile(
                  title: const Text("Active User"),
                  value: user.active,
                  onChanged: (value) async {
                    final service = ref.read(userServiceProvider);

                    await service.updateUserStatus(user.uid, value);

                    ref.refresh(userProvider(uid));
                  },
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Change Role"),
                  onPressed: () => _showRoleDialog(context, ref, user),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete User"),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete User"),
                        content: const Text(
                          "Are you sure you want to delete this user?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final service = ref.read(userServiceProvider);
                    await service.deleteUser(user.uid);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref, AppUser user) {
    String selectedRole = user.role;

    const roles = ["superAdmin", "headCoach", "coach", "trainee"];

    if (!roles.contains(selectedRole)) {
      selectedRole = "Trainee";
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change Role"),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedUser = user.copyWith(role: selectedRole);

                    await ref.read(userServiceProvider).updateUser(updatedUser);

                    ref.refresh(userProvider(user.uid));

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}