import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Super Admin screen for provisioning and managing accounts. This is
/// the UI half of the invite-only auth model — AuthService.createUser
/// already existed, but had no screen calling it.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.deepPurple;
      case UserRole.headCoach:
        return AppTheme.primary;
      case UserRole.coach:
        return AppTheme.accent;
      case UserRole.trainee:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserSheet(context, orgId),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('New User'),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _userService.watchUsers(orgId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load users: ${snapshot.error}',
                  style: TextStyle(color: Colors.grey[600])),
            );
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(
              child: Text('No users provisioned yet — tap "New User" to add your first coach or trainee',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600])),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final user = users[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _roleColor(user.role).withOpacity(0.15),
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                      style: TextStyle(color: _roleColor(user.role), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user.displayName.isEmpty ? user.email : user.displayName),
                  subtitle: Text(user.email),
                  trailing: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(user.role.label, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: _roleColor(user.role).withOpacity(0.12),
                      ),
                      if (!user.isActive)
                        const Chip(
                          label: Text('Inactive', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Color(0x1FD64545),
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'toggle') {
                            await _userService.setActive(orgId, user.id, !user.isActive);
                          } else if (value.startsWith('role:')) {
                            final newRole = UserRoleX.fromString(value.substring(5));
                            await _userService.updateRole(orgId, user.id, newRole);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(user.isActive ? 'Deactivate' : 'Reactivate'),
                          ),
                          const PopupMenuDivider(),
                          ...UserRole.values.map((r) => PopupMenuItem(
                                value: 'role:${r.name}',
                                child: Text('Set role: ${r.label}'),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateUserSheet(BuildContext context, String orgId) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole role = UserRole.trainee;
    bool saving = false;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Provision New User', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Creates a sign-in account and adds them to your organisation. '
                'Note: this will sign you out of your admin session and into '
                'the new account — sign back in afterwards.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Temporary password',
                  helperText: '6+ characters — share with the user to log in',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setSheetState(() => role = v ?? role),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty ||
                            !emailController.text.contains('@') ||
                            passwordController.text.length < 6) {
                          setSheetState(() => error = 'Fill in a valid name, email, and 6+ char password');
                          return;
                        }
                        setSheetState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await _authService.createUser(
                            organisationId: orgId,
                            email: emailController.text.trim(),
                            password: passwordController.text,
                            displayName: nameController.text.trim(),
                            role: role,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setSheetState(() {
                            saving = false;
                            error = 'Could not create user: $e';
                          });
                        }
                      },
                child: saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
