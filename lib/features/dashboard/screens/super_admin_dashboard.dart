import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../core/services/logout_service.dart';
import '../../programmes/screens/programmes_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../../users/screens/users_screen.dart';
import '../../messaging/screens/conversations_screen.dart';
// import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/app_appbar.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = FirebaseAuth.instance.currentUser;
    final programmeCount = ref.watch(programmeCountProvider);
    final totalUsers = ref.watch(totalUsersProvider);
    final coaches = ref.watch(coachesProvider);
    final trainees = ref.watch(traineesProvider);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D47A1)),
              accountName: Text(user?.displayName ?? "Super Admin"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(
                        Icons.person,
                        color: Color(0xFF0D47A1),
                        size: 40,
                      )
                    : null,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("Manage Users"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text("Programmes"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProgrammesScreen(canEdit: true, canDelete: true),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text("Sessions"),
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select a Programme and Phase first."),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text("Reports"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text("Messages"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConversationsScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                LogoutService.logout(context);
              },
            ),
          ],
        ),
      ),

      appBar: const AppAppBar(title: "Dashboard", role: UserRole.superAdmin),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            const Text(
              "Welcome,",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    user?.displayName ??
                        user?.email?.split('@').first ??
                        "Super Admin",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text("👋", style: TextStyle(fontSize: 28)),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              "Here's what's happening today.",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                DashboardCard(
                  title: "Total Users",
                  value: totalUsers.when(
                    data: (value) => value.toString(),
                    loading: () => "...",
                    error: (_, __) => "0",
                  ),
                  backgroundColor: const Color(0xffEEF4FF),
                ),

                DashboardCard(
                  title: "Coaches",
                  value: coaches.when(
                    data: (value) => value.toString(),
                    loading: () => "...",
                    error: (_, __) => "0",
                  ),
                  backgroundColor: const Color(0xffEAFBF2),
                ),

                DashboardCard(
                  title: "Trainees",
                  value: trainees.when(
                    data: (value) => value.toString(),
                    loading: () => "...",
                    error: (_, __) => "0",
                  ),
                  backgroundColor: const Color(0xffF6EEFF),
                ),

                DashboardCard(
                  title: "Programmes",
                  value: programmeCount.when(
                    data: (value) => value.toString(),
                    loading: () => "...",
                    error: (_, __) => "0",
                  ),
                  backgroundColor: const Color(0xffFFF4EA),
                  valueColor: Colors.deepOrange,
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ActionTile(
              icon: Icons.people_outline,
              title: "Manage Users",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersScreen()),
                );
              },
            ),

            ActionTile(
              icon: Icons.menu_book_outlined,
              title: "Manage Programmes",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProgrammesScreen(canEdit: true, canDelete: true),
                  ),
                );
              },
            ),

            ActionTile(
              icon: Icons.calendar_month_outlined,
              title: "View Sessions",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please open a Programme → Phase first to view Sessions.",
                    ),
                  ),
                );
              },
            ),

            ActionTile(
              icon: Icons.analytics_outlined,
              title: "Reports & Analytics",
              onTap: () {},
            ),
          ],
        ),
      ),
      // bottomNavigationBar: AppBottomNavigation(
      //   role: UserRole.superAdmin,
      //   currentIndex: 0,
      //   onTap: (index) {},
      // ),
      // bottomNavigationBar: AppBottomNavigation(
      //   role: UserRole.superAdmin,
      //   currentIndex: 0,
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         // Already on Home
      //         break;

      //       case 1:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const UsersScreen()),
      //         );
      //         break;

      //       case 2:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (_) =>
      //                 const ProgrammesScreen(canEdit: true, canDelete: true),
      //           ),
      //         );
      //         break;

      //       case 3:
      //         // Open Sessions Screen
      //         break;

      //       case 4:
      //         // Open Settings Screen
      //         break;
      //     }
      //   },
      // ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color valueColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
