/// Central reference for Firestore collection structure.
///
/// Design: organisation-scoped top level collections to support the
/// white-label multi-tenant architecture. Every document additionally
/// stores `organisationId` for defense-in-depth with security rules.
///
/// organisations/{orgId}
///   users/{userId}
///   programmes/{programmeId}
///     phases/{phaseId}
///     sessions/{sessionId}
///       attendance/{attendanceId}
///       feedbackEntries/{feedbackId}
///     taskDefinitions/{taskDefId}      <- task library, may be org-wide (no programmeId)
///     taskCompletions/{completionId}
///     skiHoursEntries/{entryId}
///   skillTags/{tagId}
///   channels/{channelId}
///     messages/{messageId}
///
/// Rationale for nesting phases/sessions under programmes rather than
/// flat top-level collections: query patterns are almost always
/// "give me everything for programme X", so nesting keeps security rules
/// simple (inherit from parent programme) and avoids composite indexes
/// for the common case. taskDefinitions/taskCompletions/skiHoursEntries
/// are still queried across programmes (e.g. "all my logged hours") so
/// those stay as org-level collections filtered by traineeId instead.
class FirestorePaths {
  static String organisation(String orgId) => 'organisations/$orgId';

  static String users(String orgId) => '${organisation(orgId)}/users';
  static String user(String orgId, String userId) => '${users(orgId)}/$userId';

  static String programmes(String orgId) => '${organisation(orgId)}/programmes';
  static String programme(String orgId, String programmeId) =>
      '${programmes(orgId)}/$programmeId';

  static String phases(String orgId, String programmeId) =>
      '${programme(orgId, programmeId)}/phases';
  static String phase(String orgId, String programmeId, String phaseId) =>
      '${phases(orgId, programmeId)}/$phaseId';

  static String sessions(String orgId, String programmeId) =>
      '${programme(orgId, programmeId)}/sessions';
  static String session(String orgId, String programmeId, String sessionId) =>
      '${sessions(orgId, programmeId)}/$sessionId';

  static String attendance(String orgId, String programmeId, String sessionId) =>
      '${session(orgId, programmeId, sessionId)}/attendance';

  static String feedbackEntries(String orgId, String programmeId, String sessionId) =>
      '${session(orgId, programmeId, sessionId)}/feedbackEntries';

  static String taskDefinitions(String orgId) => '${organisation(orgId)}/taskDefinitions';
  static String taskCompletions(String orgId) => '${organisation(orgId)}/taskCompletions';
  static String skiHoursEntries(String orgId) => '${organisation(orgId)}/skiHoursEntries';
  static String skillTags(String orgId) => '${organisation(orgId)}/skillTags';

  static String channels(String orgId) => '${organisation(orgId)}/channels';
  static String messages(String orgId, String channelId) =>
      '${channels(orgId)}/$channelId/messages';
}
