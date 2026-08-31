import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/logout_service.dart';
// import '../../../core/widgets/app_bottom_navigation.dart';
import '../../attendance/screens/my_attendance_screen.dart';
// import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/app_appbar.dart';

class TraineeDashboard extends StatelessWidget {
  const TraineeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "Trainee"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.school),
              title: const Text("My Sessions"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("My Tasks"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.fact_check),
              title: const Text("My Attendance"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyAttendanceScreen()),
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

      appBar: const AppAppBar(title: "Dashboard", role: UserRole.trainee),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello,",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              user?.displayName ?? user?.email?.split('@').first ?? "Trainee",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 25),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: const [
                DashboardCard(title: "My Sessions", value: "2"),
                DashboardCard(title: "My Tasks", value: "4"),
                DashboardCard(title: "Progress", value: "72%"),
                DashboardCard(title: "Attendance", value: "90%"),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: const [
                    ScheduleTile(time: "06:00 AM", title: "Fitness Training"),
                    Divider(),
                    ScheduleTile(time: "04:00 PM", title: "On Snow Session"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: AppBottomNavigation(
      //   role: UserRole.trainee,
      //   currentIndex: 0,
      //   onTap: (index) {},
      // ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleTile extends StatelessWidget {
  final String time;
  final String title;

  const ScheduleTile({super.key, required this.time, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
