import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Handles local caching and outbox-style write queueing so the app stays
/// usable with no/poor signal on the mountain, then syncs when connectivity
/// returns.
///
/// Pattern used: "outbox queue". Every write that happens while offline
/// (attendance marks, task submissions, feedback entries, ski-hours logs,
/// chat messages) is appended to a Hive box as a pending operation. When
/// connectivity is restored, [processPendingQueue] replays them against
/// Firestore in order. Firestore's own offline persistence handles read
/// caching automatically; this service specifically covers writes that
/// need app-level retry/visibility (e.g. showing a "pending sync" badge).
class OfflineService {
  static const String _pendingBoxName = 'pending_writes';
  static const String _cacheBoxName = 'local_cache';

  late Box _pendingBox;
  late Box _cacheBox;
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final StreamController<bool> _onlineStatusController = StreamController<bool>.broadcast();
  Stream<bool> get onlineStatus => _onlineStatusController.stream;

  /// Callback wired up by main.dart / providers to actually perform the
  /// Firestore write for a queued operation. Kept generic so this service
  /// has no direct dependency on specific model types.
  Future<void> Function(PendingWrite write)? onProcessWrite;

  Future<void> init() async {
    await Hive.initFlutter();
    _pendingBox = await Hive.openBox(_pendingBoxName);
    _cacheBox = await Hive.openBox(_cacheBoxName);

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      _onlineStatusController.add(isOnline);
      if (isOnline) {
        processPendingQueue();
      }
    });
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Queue a write to be replayed once back online. Returns immediately so
  /// the UI can optimistically update (e.g. show "saved, will sync").
  Future<void> queueWrite(PendingWrite write) async {
    await _pendingBox.add(write.toMap());
  }

  int get pendingCount => _pendingBox.length;

  Future<void> processPendingQueue() async {
    if (onProcessWrite == null) return;
    final keys = _pendingBox.keys.toList();
    for (final key in keys) {
      final raw = _pendingBox.get(key);
      if (raw == null) continue;
      final write = PendingWrite.fromMap(Map<String, dynamic>.from(raw));
      try {
        await onProcessWrite!(write);
        await _pendingBox.delete(key);
      } catch (_) {
        // Leave in queue, will retry on next connectivity event.
        break;
      }
    }
  }

  // Simple key/value local cache for read-through offline viewing
  // (e.g. today's session list, task library) independent of the
  // Firestore SDK's own offline cache — useful for data we want
  // guaranteed available even before first Firestore sync completes.
  Future<void> cacheSet(String key, dynamic value) => _cacheBox.put(key, value);
  dynamic cacheGet(String key) => _cacheBox.get(key);

  void dispose() {
    _sub?.cancel();
    _onlineStatusController.close();
  }
}

/// A single queued offline write operation.
class PendingWrite {
  final String collectionPath;
  final String? docId; // null = create new doc
  final Map<String, dynamic> data;
  final PendingWriteOp operation;
  final DateTime queuedAt;

  PendingWrite({
    required this.collectionPath,
    this.docId,
    required this.data,
    required this.operation,
    required this.queuedAt,
  });

  Map<String, dynamic> toMap() => {
        'collectionPath': collectionPath,
        'docId': docId,
        'data': data,
        'operation': operation.name,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory PendingWrite.fromMap(Map<String, dynamic> map) => PendingWrite(
        collectionPath: map['collectionPath'],
        docId: map['docId'],
        data: Map<String, dynamic>.from(map['data']),
        operation: PendingWriteOp.values.firstWhere((o) => o.name == map['operation']),
        queuedAt: DateTime.parse(map['queuedAt']),
      );
}

enum PendingWriteOp { create, update, delete }
