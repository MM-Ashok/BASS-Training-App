import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/message_provider.dart';
import 'chat_screen.dart';
import 'new_message_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    final conversationsAsync = ref.watch(
      conversationsProvider(currentUser.uid),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewMessageScreen()),
          );
        },
      ),

      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return const Center(child: Text("No conversations yet."));
          }

          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final conversation = snapshot.docs[index];

              final data = conversation.data();

              final participants = List<String>.from(
                data["participants"] ?? [],
              );

              participants.remove(currentUser.uid);

              final otherUserId = participants.isEmpty
                  ? ""
                  : participants.first;

              final lastMessage = data["lastMessage"] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),

                  title: Text(
                    otherUserId.isEmpty ? "Unknown User" : otherUserId,
                  ),

                  subtitle: Text(lastMessage),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: conversation.id,
                          receiverId: otherUserId,
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
