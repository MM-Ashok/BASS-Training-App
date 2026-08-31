import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../core/services/logout_service.dart';
import '../../programmes/screens/programmes_screen.dart';
// import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/app_appbar.dart';

class HeadCoachDashboard extends StatelessWidget {
  const HeadCoachDashboard({super.key});

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
              decoration: const BoxDecoration(color: Colors.green),
              accountName: Text(user?.displayName ?? "Head Coach"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.green, size: 40)
                    : null,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text("My Coaches"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("Trainees"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text("Sessions"),
              onTap: () {},
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
                        const ProgrammesScreen(canEdit: true, canDelete: false),
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

      appBar: const AppAppBar(title: "Dashboard", role: UserRole.headCoach),

      
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
                        "Head Coach",
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
              "Here's your overview today.",
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
                  title: "My Coaches",
                  value: "5",
                  backgroundColor: Color(0xffEEF9F0),
                ),
                DashboardCard(
                  title: "Trainees",
                  value: "48",
                  backgroundColor: Color(0xffEEF9F0),
                ),
                DashboardCard(
                  title: "Sessions Today",
                  value: "3",
                  backgroundColor: Color(0xffF6EEFF),
                ),
                DashboardCard(
                  title: "Pending Tasks",
                  value: "7",
                  backgroundColor: Color(0xffFFF1F1),
                  valueColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Today's Sessions",
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
                    time: "07:00 AM",
                    title: "Strength Training",
                    subtitle: "U16 Team",
                  ),
                  Divider(height: 1),
                  SessionTile(
                    time: "09:30 AM",
                    title: "On Snow Technique",
                    subtitle: "U18 Team",
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
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: AppBottomNavigation(
      //   role: UserRole.headCoach,
      //   currentIndex: 0,
      //   onTap: (index) {},
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
