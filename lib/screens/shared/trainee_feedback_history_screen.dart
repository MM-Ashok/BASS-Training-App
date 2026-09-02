import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

/// Trainee-facing view of their own feedback history across every
/// session/programme, with a "cross-reference by skill" filter — this is
/// the "cross-reference" half of the skills-framework tagging requirement.
class TraineeFeedbackHistoryScreen extends StatefulWidget {
  const TraineeFeedbackHistoryScreen({super.key});

  @override
  State<TraineeFeedbackHistoryScreen> createState() => _TraineeFeedbackHistoryScreenState();
}

class _TraineeFeedbackHistoryScreenState extends State<TraineeFeedbackHistoryScreen> {
  String? _selectedSkillTagId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final provider = context.read<FeedbackProvider>();
    provider.init(orgId);
    if (auth.currentUser != null) {
      provider.watchTrainee(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedbackProvider>();
    final auth = context.watch<AuthProvider>();
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('My Feedback Journal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedSkillTagId == null,
                  onSelected: (_) {
                    setState(() => _selectedSkillTagId = null);
                    if (auth.currentUser != null) provider.watchTrainee(auth.currentUser!.id);
                  },
                ),
                ...provider.skillTags.map((tag) => ChoiceChip(
                      label: Text(tag.name),
                      selected: _selectedSkillTagId == tag.id,
                      onSelected: (_) {
                        setState(() => _selectedSkillTagId = tag.id);
                        if (auth.currentUser != null) {
                          provider.watchTrainee(auth.currentUser!.id, skillTagId: tag.id);
                        }
                      },
                    )),
              ],
            ),
          ),
          Expanded(
            child: provider.traineeEntries.isEmpty
                ? Center(
                    child: Text('No feedback entries yet',
                        style: TextStyle(color: Colors.grey[600])))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.traineeEntries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final entry = provider.traineeEntries[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateFmt.format(entry.createdAt),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(entry.content),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
