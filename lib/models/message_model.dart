enum ChannelType { teamChannel, programmeBroadcast, directMessage }

class MessageChannel {
  final String id;
  final String organisationId;
  final String? programmeId;
  final String title;
  final ChannelType type;
  final List<String> memberIds;
  final DateTime createdAt;

  MessageChannel({
    required this.id,
    required this.organisationId,
    this.programmeId,
    required this.title,
    required this.type,
    this.memberIds = const [],
    required this.createdAt,
  });

  factory MessageChannel.fromMap(String id, Map<String, dynamic> map) {
    return MessageChannel(
      id: id,
      organisationId: map['organisationId'] ?? '',
      programmeId: map['programmeId'],
      title: map['title'] ?? '',
      type: ChannelType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ChannelType.teamChannel,
      ),
      memberIds: List<String>.from(map['memberIds'] ?? const []),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organisationId': organisationId,
      'programmeId': programmeId,
      'title': title,
      'type': type.name,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String channelId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isBroadcast; // one-way, only head coach/admin can send
  final bool pendingSync; // true while queued for offline sync

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.isBroadcast = false,
    this.pendingSync = false,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      channelId: map['channelId'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      sentAt: DateTime.tryParse(map['sentAt'] ?? '') ?? DateTime.now(),
      isBroadcast: map['isBroadcast'] ?? false,
      pendingSync: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'senderId': senderId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isBroadcast': isBroadcast,
    };
  }
}
