import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/message_model.dart';
import '../providers/message_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final _uuid = const Uuid();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final currentUser =
        FirebaseAuth.instance.currentUser!;

    final message = MessageModel(
      id: _uuid.v4(),
      conversationId: widget.conversationId,

      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? "",

      receiverId: widget.receiverId,
      receiverName: "",

      text: text,

      attachmentUrl: "",

      isRead: false,

      sentAt: DateTime.now(),
    );

    await ref
        .read(messageServiceProvider)
        .sendMessage(message);

    _messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        FirebaseAuth.instance.currentUser!;

    final messagesAsync = ref.watch(
      messagesProvider(
        ConversationParams(
          conversationId: widget.conversationId,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),

      body: Column(
        children: [

          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(),
              ),

              error: (e, _) => Center(
                child: Text(e.toString()),
              ),

              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet.",
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (_scrollController
                      .hasClients) {
                    _scrollController.jumpTo(
                      _scrollController
                          .position
                          .maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message =
                        messages[index];

                    final isMine =
                        message.senderId ==
                            currentUser.uid;

                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(
                          vertical: 4,
                        ),

                        padding:
                            const EdgeInsets.all(12),

                        constraints:
                            const BoxConstraints(
                          maxWidth: 280,
                        ),

                        decoration: BoxDecoration(
                          color: isMine
                              ? Colors.blue
                              : Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              "${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller:
                          _messageController,
                      decoration:
                          const InputDecoration(
                        hintText:
                            "Type a message...",
                        border:
                            OutlineInputBorder(),
                      ),
                      textCapitalization:
                          TextCapitalization
                              .sentences,
                    ),
                  ),

                  const SizedBox(width: 10),

                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blue,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}