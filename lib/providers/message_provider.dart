import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessagingService _service = MessagingService();
  final _uuid = const Uuid();
  String? _organisationId;

  List<MessageChannel> channels = [];
  List<ChatMessage> activeMessages = [];

  StreamSubscription? _channelsSub;
  StreamSubscription? _messagesSub;

  void init(String organisationId, String userId) {
    _organisationId = organisationId;
    _channelsSub?.cancel();
    _channelsSub = _service.watchChannelsForUser(organisationId, userId).listen((data) {
      channels = data;
      notifyListeners();
    });
  }

  Future<void> createChannel({
    required String title,
    required ChannelType type,
    required List<String> memberIds,
    String? programmeId,
  }) async {
    if (_organisationId == null) return;
    final channel = MessageChannel(
      id: _uuid.v4(),
      organisationId: _organisationId!,
      programmeId: programmeId,
      title: title,
      type: type,
      memberIds: memberIds,
      createdAt: DateTime.now(),
    );
    await _service.createChannel(_organisationId!, channel);
  }

  void watchMessages(String channelId) {
    if (_organisationId == null) return;
    _messagesSub?.cancel();
    _messagesSub = _service.watchMessages(_organisationId!, channelId).listen((data) {
      activeMessages = data;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String channelId,
    required String senderId,
    required String content,
    bool isBroadcast = false,
  }) async {
    if (_organisationId == null) return;
    final message = ChatMessage(
      id: _uuid.v4(),
      channelId: channelId,
      senderId: senderId,
      content: content,
      sentAt: DateTime.now(),
      isBroadcast: isBroadcast,
    );
    await _service.sendMessage(_organisationId!, message);
  }

  @override
  void dispose() {
    _channelsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
