import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;

  /// Conversation
  final String conversationId;

  /// Sender
  final String senderId;
  final String senderName;

  /// Receiver
  final String receiverId;
  final String receiverName;

  /// Message
  final String text;

  /// Optional attachment
  final String attachmentUrl;

  /// Read status
  final bool isRead;

  /// Sent time
  final DateTime sentAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.text,
    required this.attachmentUrl,
    required this.isRead,
    required this.sentAt,
  });

  factory MessageModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return MessageModel(
      id: id,
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      text: map['text'] ?? '',
      attachmentUrl: map['attachmentUrl'] ?? '',
      isRead: map['isRead'] ?? false,
      sentAt: map['sentAt'] != null
          ? (map['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'text': text,
      'attachmentUrl': attachmentUrl,
      'isRead': isRead,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  MessageModel copyWith({
    String? conversationId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? text,
    String? attachmentUrl,
    bool? isRead,
    DateTime? sentAt,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      text: text ?? this.text,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}