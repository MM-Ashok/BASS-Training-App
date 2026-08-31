import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/logout_service.dart';
// import '../../../core/widgets/app_bottom_navigation.dart';
// import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/app_appbar.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    print(user);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: Text(
                user?.displayName ?? user?.email?.split('@').first ?? "Coach",
              ),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.deepPurple,
                        size: 40,
                      )
                    : null,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("My Trainees"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text("Sessions"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text("Tasks"),
              onTap: () {},
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

      appBar: const AppAppBar(title: "Dashboard", role: UserRole.coach),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        "Coach",
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
              "Here's your plan for today.",
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
              children: const [
                DashboardCard(
                  title: "My Trainees",
                  value: "18",
                  backgroundColor: Color(0xffF5F0FF),
                ),
                DashboardCard(
                  title: "Sessions Today",
                  value: "2",
                  backgroundColor: Color(0xffF5F0FF),
                ),
                DashboardCard(
                  title: "My Tasks",
                  value: "5",
                  backgroundColor: Color(0xffF9F0FF),
                ),
                DashboardCard(
                  title: "Attendance",
                  value: "85%",
                  backgroundColor: Color(0xffFFF6EE),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  SessionTile(
                    time: "08:00 AM",
                    title: "Warm Up & Mobility",
                    subtitle: "Group A",
                  ),
                  Divider(height: 1),
                  SessionTile(
                    time: "10:00 AM",
                    title: "Skill Training",
                    subtitle: "Group B",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: AppBottomNavigation(
      //   role: UserRole.coach,
      //   currentIndex: 0,
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         // Home
      //         break;

      //       case 1:
      //         // Trainees
      //         break;

      //       case 2:
      //         // Sessions
      //         break;

      //       case 3:
      //         // Tasks
      //         break;

      //       case 4:
      //         // More
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

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
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
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SessionTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;

  const SessionTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 55,
        child: Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
