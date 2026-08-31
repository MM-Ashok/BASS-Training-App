import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/session_model.dart';
import '../services/session_service.dart';

/// Session Service
final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

/// Get all sessions of a phase
final sessionsProvider = StreamProvider.family<
    List<SessionModel>,
    SessionParams>((ref, params) {
  return ref.read(sessionServiceProvider).getSessions(
        params.programmeId,
        params.phaseId,
      );
});

/// Get single session
final sessionProvider = StreamProvider.family<
    SessionModel?,
    SessionDetailParams>((ref, params) {
  return ref.read(sessionServiceProvider).getSession(
        params.programmeId,
        params.phaseId,
        params.sessionId,
      );
});

/// Parameters for session list
class SessionParams {
  final String programmeId;
  final String phaseId;

  const SessionParams({
    required this.programmeId,
    required this.phaseId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionParams &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId;

  @override
  int get hashCode => Object.hash(programmeId, phaseId);
}

/// Parameters for single session
class SessionDetailParams {
  final String programmeId;
  final String phaseId;
  final String sessionId;

  const SessionDetailParams({
    required this.programmeId,
    required this.phaseId,
    required this.sessionId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionDetailParams &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId &&
          sessionId == other.sessionId;

  @override
  int get hashCode =>
      Object.hash(programmeId, phaseId, sessionId);
}