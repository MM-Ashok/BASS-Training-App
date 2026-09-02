/// A single skills-framework tag (e.g. "Edge Control", "Client Communication").
/// Kept as a lightweight reference model so tags stay consistent and
/// cross-reference-able across sessions, tasks and the feedback journal.
class SkillTag {
  final String id;
  final String name;
  final String category; // e.g. "Technical", "Teaching", "Safety"

  SkillTag({required this.id, required this.name, required this.category});

  factory SkillTag.fromMap(String id, Map<String, dynamic> map) {
    return SkillTag(id: id, name: map['name'] ?? '', category: map['category'] ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name, 'category': category};
}

/// A feedback journal entry written after a session — by a coach about a
/// trainee, or a trainee's self-reflection. Tagged against the skills
/// framework so entries can be cross-referenced by skill over time.
class FeedbackEntry {
  final String id;
  final String sessionId;
  final String traineeId;
  final String authorId; // coach or the trainee themself (self-reflection)
  final FeedbackAuthorType authorType;
  final String content;
  final List<String> skillTagIds;
  final int? ratingOutOfFive;
  final bool isVoiceTranscribed; // true if captured via speech-to-text
  final DateTime createdAt;

  FeedbackEntry({
    required this.id,
    required this.sessionId,
    required this.traineeId,
    required this.authorId,
    required this.authorType,
    required this.content,
    this.skillTagIds = const [],
    this.ratingOutOfFive,
    this.isVoiceTranscribed = false,
    required this.createdAt,
  });

  factory FeedbackEntry.fromMap(String id, Map<String, dynamic> map) {
    return FeedbackEntry(
      id: id,
      sessionId: map['sessionId'] ?? '',
      traineeId: map['traineeId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorType: FeedbackAuthorType.values.firstWhere(
        (a) => a.name == map['authorType'],
        orElse: () => FeedbackAuthorType.coach,
      ),
      content: map['content'] ?? '',
      skillTagIds: List<String>.from(map['skillTagIds'] ?? const []),
      ratingOutOfFive: map['ratingOutOfFive'],
      isVoiceTranscribed: map['isVoiceTranscribed'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'traineeId': traineeId,
      'authorId': authorId,
      'authorType': authorType.name,
      'content': content,
      'skillTagIds': skillTagIds,
      'ratingOutOfFive': ratingOutOfFive,
      'isVoiceTranscribed': isVoiceTranscribed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum FeedbackAuthorType { coach, trainee }
