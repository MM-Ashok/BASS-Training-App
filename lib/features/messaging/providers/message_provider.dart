import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/message_model.dart';
import '../services/message_service.dart';

/// ======================================================
/// Message Service
/// ======================================================

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});

/// ======================================================
/// Conversation Parameters
/// ======================================================

class ConversationParams {
  final String conversationId;

  const ConversationParams({
    required this.conversationId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationParams &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId;

  @override
  int get hashCode => conversationId.hashCode;
}

/// ======================================================
/// Conversation Messages
/// ======================================================

final messagesProvider = StreamProvider.family<
    List<MessageModel>,
    ConversationParams>((ref, params) {
  return ref
      .read(messageServiceProvider)
      .getMessages(
        params.conversationId,
      );
});

/// ======================================================
/// Single Message Parameters
/// ======================================================

class MessageParams {
  final String conversationId;
  final String messageId;

  const MessageParams({
    required this.conversationId,
    required this.messageId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageParams &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId &&
          messageId == other.messageId;

  @override
  int get hashCode =>
      Object.hash(
        conversationId,
        messageId,
      );
}

/// ======================================================
/// Single Message
/// ======================================================

final messageProvider = StreamProvider.family<
    MessageModel?,
    MessageParams>((ref, params) {
  return ref
      .read(messageServiceProvider)
      .getMessage(
        params.conversationId,
        params.messageId,
      );
});

/// ======================================================
/// User Conversations
/// ======================================================

final conversationsProvider =
    StreamProvider.family((ref, String userId) {
  return ref
      .read(messageServiceProvider)
      .getConversations(userId);
});