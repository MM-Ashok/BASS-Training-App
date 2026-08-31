import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../authentication/providers/user_provider.dart';
import 'chat_screen.dart';

class NewMessageScreen extends ConsumerWidget {
  const NewMessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in."),
        ),
      );
    }

    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
      ),
      body: usersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (users) {
          final availableUsers = users
              .where((u) => u.uid != currentUser.uid)
              .toList();

          if (availableUsers.isEmpty) {
            return const Center(
              child: Text("No users found."),
            );
          }

          return ListView.builder(
            itemCount: availableUsers.length,
            itemBuilder: (_, index) {
              final AppUser user = availableUsers[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  title: Text(user.name),

                  subtitle: Text(
                    "${user.role} • ${user.email}",
                  ),

                  trailing:
                      const Icon(Icons.chevron_right),

                  onTap: () {
                    final ids = [
                      currentUser.uid,
                      user.uid,
                    ]..sort();

                    final conversationId =
                        ids.join("_");

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId:
                              conversationId,
                          receiverId: user.uid,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}