import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import 'firestore_paths.dart';

class MessagingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createChannel(String orgId, MessageChannel channel) async {
    final ref = await _db.collection(FirestorePaths.channels(orgId)).add(channel.toMap());
    return ref.id;
  }

  Stream<List<MessageChannel>> watchChannelsForUser(String orgId, String userId) {
    return _db
        .collection(FirestorePaths.channels(orgId))
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageChannel.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendMessage(String orgId, ChatMessage message) async {
    await _db
        .collection(FirestorePaths.messages(orgId, message.channelId))
        .add(message.toMap());
  }

  Stream<List<ChatMessage>> watchMessages(String orgId, String channelId) {
    return _db
        .collection(FirestorePaths.messages(orgId, channelId))
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }
}
