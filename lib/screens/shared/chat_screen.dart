import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';

class ChatScreen extends StatefulWidget {
  final MessageChannel channel;
  const ChatScreen({super.key, required this.channel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MessageProvider>().watchMessages(widget.channel.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _canSend(UserRole? role) {
    if (widget.channel.type != ChannelType.programmeBroadcast) return true;
    // Broadcasts are one-way: only head coach / super admin can post.
    return role == UserRole.headCoach || role == UserRole.superAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final auth = context.watch<AuthProvider>();
    final dateFmt = DateFormat('HH:mm');
    final canSend = _canSend(auth.role);

    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.title)),
      body: Column(
        children: [
          Expanded(
            child: provider.activeMessages.isEmpty
                ? Center(child: Text('No messages yet', style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.activeMessages.length,
                    itemBuilder: (context, i) {
                      final msg = provider.activeMessages[i];
                      final isMine = msg.senderId == auth.currentUser?.id;
                      return Align(
                        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMine ? AppTheme.primary : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg.content,
                                  style: TextStyle(color: isMine ? Colors.white : Colors.black87)),
                              const SizedBox(height: 2),
                              Text(dateFmt.format(msg.sentAt),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: isMine ? Colors.white70 : Colors.grey[600])),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (!canSend)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: const Text(
                'This is a one-way programme broadcast — only your Head Coach can post here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Message...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (_controller.text.trim().isEmpty) return;
                        await context.read<MessageProvider>().sendMessage(
                              channelId: widget.channel.id,
                              senderId: auth.currentUser?.id ?? 'demo-user',
                              content: _controller.text.trim(),
                              isBroadcast: widget.channel.type == ChannelType.programmeBroadcast,
                            );
                        _controller.clear();
                      },
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
