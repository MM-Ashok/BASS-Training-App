import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ======================================================
  /// Conversation Collection
  /// ======================================================

  CollectionReference<Map<String, dynamic>> get _conversationCollection =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messageCollection(
    String conversationId,
  ) {
    return _conversationCollection
        .doc(conversationId)
        .collection('messages');
  }

  /// ======================================================
  /// Create Conversation
  /// ======================================================

  Future<void> createConversation({
    required String conversationId,
    required List<String> participants,
  }) async {
    final doc = await _conversationCollection.doc(conversationId).get();

    if (doc.exists) return;

    await _conversationCollection.doc(conversationId).set({
      'participants': participants,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ======================================================
  /// Send Message
  /// ======================================================

  Future<void> sendMessage(MessageModel message) async {
    await createConversation(
      conversationId: message.conversationId,
      participants: [
        message.senderId,
        message.receiverId,
      ],
    );

    await _messageCollection(message.conversationId)
        .doc(message.id)
        .set(message.toMap());

    await _conversationCollection
        .doc(message.conversationId)
        .update({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ======================================================
  /// Get Messages
  /// ======================================================

  Stream<List<MessageModel>> getMessages(
    String conversationId,
  ) {
    return _messageCollection(conversationId)
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// ======================================================
  /// Get Single Message
  /// ======================================================

  Stream<MessageModel?> getMessage(
    String conversationId,
    String messageId,
  ) {
    return _messageCollection(conversationId)
        .doc(messageId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      return MessageModel.fromMap(
        doc.data()!,
        doc.id,
      );
    });
  }

  /// ======================================================
  /// Mark As Read
  /// ======================================================

  Future<void> markAsRead(
    String conversationId,
    String messageId,
  ) async {
    await _messageCollection(
      conversationId,
    ).doc(messageId).update({
      'isRead': true,
    });
  }

  /// ======================================================
  /// Update Message
  /// ======================================================

  Future<void> updateMessage(
    MessageModel message,
  ) async {
    await _messageCollection(
      message.conversationId,
    ).doc(message.id).update(
          message.toMap(),
        );
  }

  /// ======================================================
  /// Delete Message
  /// ======================================================

  Future<void> deleteMessage(
    String conversationId,
    String messageId,
  ) async {
    await _messageCollection(
      conversationId,
    ).doc(messageId).delete();
  }

  /// ======================================================
  /// Conversations
  /// ======================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversations(
    String userId,
  ) {
    return _conversationCollection
        .where(
          'participants',
          arrayContains: userId,
        )
        .orderBy(
          'updatedAt',
          descending: true,
        )
        .snapshots();
  }
}