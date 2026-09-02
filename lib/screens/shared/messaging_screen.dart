import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'chat_screen.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    if (auth.currentUser != null) {
      context.read<MessageProvider>().init(orgId, auth.currentUser!.id);
    }
  }

  IconData _iconFor(ChannelType type) {
    switch (type) {
      case ChannelType.teamChannel:
        return Icons.groups_outlined;
      case ChannelType.programmeBroadcast:
        return Icons.campaign_outlined;
      case ChannelType.directMessage:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final auth = context.watch<AuthProvider>();
    final canBroadcast =
        auth.role == UserRole.headCoach || auth.role == UserRole.superAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateChannelDialog(context, canBroadcast, auth),
        icon: const Icon(Icons.add),
        label: const Text('New Channel'),
      ),
      body: provider.channels.isEmpty
          ? Center(
              child: Text('No channels yet — team channels, programme broadcasts\nand DMs will show up here',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600])))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.channels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final channel = provider.channels[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Icon(_iconFor(channel.type), color: AppTheme.primary, size: 20),
                    ),
                    title: Text(channel.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_typeLabel(channel.type)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatScreen(channel: channel)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _typeLabel(ChannelType t) {
    switch (t) {
      case ChannelType.teamChannel:
        return 'Team channel';
      case ChannelType.programmeBroadcast:
        return 'Programme broadcast (one-way)';
      case ChannelType.directMessage:
        return 'Direct message';
    }
  }

  void _showCreateChannelDialog(BuildContext context, bool canBroadcast, AuthProvider auth) {
    final titleController = TextEditingController();
    ChannelType type = ChannelType.teamChannel;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Channel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Channel name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ChannelType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  const DropdownMenuItem(
                      value: ChannelType.teamChannel, child: Text('Team channel')),
                  if (canBroadcast)
                    const DropdownMenuItem(
                        value: ChannelType.programmeBroadcast,
                        child: Text('Programme broadcast')),
                  const DropdownMenuItem(
                      value: ChannelType.directMessage, child: Text('Direct message')),
                ],
                onChanged: (v) => setDialogState(() => type = v ?? type),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await context.read<MessageProvider>().createChannel(
                      title: titleController.text.trim(),
                      type: type,
                      memberIds: [auth.currentUser?.id ?? 'demo-user'],
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
