import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

/// Shared shell for every role dashboard: app bar with user info + logout,
/// and a simple grid of feature tiles. Kept generic so each role's
/// dashboard file just supplies its own tile list.
class RoleDashboardScaffold extends StatelessWidget {
  final String roleLabel;
  final List<DashboardTile> tiles;
  final Widget? body;

  const RoleDashboardScaffold({
    super.key,
    required this.roleLabel,
    this.tiles = const [],
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(roleLabel),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       tooltip: 'Sign out',
      //       onPressed: () => context.read<AuthProvider>().logout(),
      //     ),
      //   ],
      // ),
      appBar: AppBar(
          title: Text(roleLabel),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text(
                      'Are you sure you want to sign out?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await context.read<AuthProvider>().logout();
                }
              },
            ),
          ],
        ),
      body: body ??
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Welcome back${user != null ? ", ${user.displayName}" : ""}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => tiles[i],
                    childCount: tiles.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;

  const DashboardTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title — coming soon in Phase 2 build-out')),
                ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Role guard: wrap any screen body in this to enforce that only the
/// allowed roles can view it (defense-in-depth alongside Firestore rules).
class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;

  const RoleGuard({super.key, required this.allowedRoles, required this.child});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    if (role == null || !allowedRoles.contains(role)) {
      return const Scaffold(
        body: Center(child: Text("You don't have access to this section.")),
      );
    }
    return child;
  }
}
