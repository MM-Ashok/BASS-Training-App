import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/feedback_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// Feedback journal for a single session. Coaches write feedback about a
/// trainee; trainees can add self-reflections. Entries are tagged against
/// the skills framework so they can be cross-referenced later (see the
/// "By Skill" filter, which queries FeedbackProvider.watchTrainee with a
/// skillTagId across the trainee's whole history, not just this session).
class FeedbackJournalScreen extends StatefulWidget {
  final String programmeId;
  final String sessionId;
  final String traineeId;
  final String traineeName;

  const FeedbackJournalScreen({
    super.key,
    required this.programmeId,
    required this.sessionId,
    required this.traineeId,
    required this.traineeName,
  });

  @override
  State<FeedbackJournalScreen> createState() => _FeedbackJournalScreenState();
}

class _FeedbackJournalScreenState extends State<FeedbackJournalScreen> {
  @override
  void initState() {
    super.initState();
    final orgId =
        context.read<AuthProvider>().currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final provider = context.read<FeedbackProvider>();
    provider.init(orgId);
    provider.watchSession(widget.programmeId, widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedbackProvider>();
    final auth = context.watch<AuthProvider>();
    final dateFmt = DateFormat('MMM d, HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('Feedback · ${widget.traineeName}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeSheet(context, auth),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Add Entry'),
      ),
      body: provider.sessionEntries.isEmpty
          ? Center(
              child: Text('No feedback logged for this session yet',
                  style: TextStyle(color: Colors.grey[600])))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.sessionEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final entry = provider.sessionEntries[i];
                final tagNames = provider.skillTags
                    .where((t) => entry.skillTagIds.contains(t.id))
                    .map((t) => t.name)
                    .toList();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              entry.authorType == FeedbackAuthorType.coach
                                  ? Icons.sports
                                  : Icons.self_improvement,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              entry.authorType == FeedbackAuthorType.coach
                                  ? 'Coach feedback'
                                  : 'Self-reflection',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Spacer(),
                            if (entry.isVoiceTranscribed)
                              const Icon(Icons.mic, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(dateFmt.format(entry.createdAt),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(entry.content),
                        if (entry.ratingOutOfFive != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < entry.ratingOutOfFive! ? Icons.star : Icons.star_border,
                                size: 16,
                                color: AppTheme.warning,
                              ),
                            ),
                          ),
                        ],
                        if (tagNames.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: tagNames
                                .map((t) => Chip(
                                      label: Text(t, style: const TextStyle(fontSize: 11)),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: AppTheme.primary.withOpacity(0.08),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showComposeSheet(BuildContext context, AuthProvider auth) {
    final contentController = TextEditingController();
    final provider = context.read<FeedbackProvider>();
    final selectedTagIds = <String>{};
    int? rating;
    final speech = stt.SpeechToText();
    bool isListening = false;
    bool speechAvailable = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Feedback Entry', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  hintText: 'What did you observe this session?',
                  suffixIcon: IconButton(
                    icon: Icon(isListening ? Icons.mic : Icons.mic_none,
                        color: isListening ? AppTheme.danger : null),
                    tooltip: 'Dictate feedback',
                    onPressed: () async {
                      if (!isListening) {
                        speechAvailable = await speech.initialize();
                        if (!speechAvailable) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                content: Text('Voice input unavailable on this device')));
                          }
                          return;
                        }
                        setSheetState(() => isListening = true);
                        speech.listen(
                          onResult: (result) {
                            contentController.text = result.recognizedWords;
                            setSheetState(() {});
                          },
                        );
                      } else {
                        speech.stop();
                        setSheetState(() => isListening = false);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Skills covered', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: provider.skillTags.map((tag) {
                  final selected = selectedTagIds.contains(tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: selected,
                    onSelected: (v) => setSheetState(
                        () => v ? selectedTagIds.add(tag.id) : selectedTagIds.remove(tag.id)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text('Rating (optional)', style: Theme.of(ctx).textTheme.labelLarge),
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      (rating ?? 0) > i ? Icons.star : Icons.star_border,
                      color: AppTheme.warning,
                    ),
                    onPressed: () => setSheetState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (contentController.text.trim().isEmpty) return;
                  await provider.addEntry(
                    programmeId: widget.programmeId,
                    sessionId: widget.sessionId,
                    traineeId: widget.traineeId,
                    authorId: auth.currentUser?.id ?? 'demo-user',
                    authorType: auth.role == UserRole.trainee
                        ? FeedbackAuthorType.trainee
                        : FeedbackAuthorType.coach,
                    content: contentController.text.trim(),
                    skillTagIds: selectedTagIds.toList(),
                    rating: rating,
                    isVoiceTranscribed: isListening || speechAvailable,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
