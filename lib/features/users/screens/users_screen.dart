import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../features/authentication/providers/user_provider.dart';
import 'create_user_screen.dart';
import 'user_detail_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String search = "";
  String selectedRole = "All";

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Users")),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text("Add User"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateUserScreen()),
          );
        },
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Role",
              ),
              items: const [
                DropdownMenuItem(value: "All", child: Text("All")),
                DropdownMenuItem(
                  value: "superAdmin",
                  child: Text("Super Admin"),
                ),
                DropdownMenuItem(value: "headCoach", child: Text("Head Coach")),
                DropdownMenuItem(value: "coach", child: Text("Coach")),
                DropdownMenuItem(value: "trainee", child: Text("Trainee")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text(e.toString())),

              data: (users) {
                List<AppUser> filtered = users.where((user) {
                  final matchesSearch =
                      user.name.toLowerCase().contains(search) ||
                      user.email.toLowerCase().contains(search);

                  final matchesRole =
                      selectedRole == "All" || user.role == selectedRole;

                  return matchesSearch && matchesRole;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final user = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.name.isEmpty
                                ? "?"
                                : user.name[0].toUpperCase(),
                          ),
                        ),

                        title: Text(user.name),

                        subtitle: Text("${user.role}\n${user.email}"),

                        isThreeLine: true,

                        trailing: Chip(
                          backgroundColor: user.active
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          label: Text(user.active ? "Active" : "Inactive"),
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(uid: user.uid),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
