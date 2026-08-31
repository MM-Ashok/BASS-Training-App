import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/experience_model.dart';

import '../providers/experience_provider.dart';
import 'edit_experience_screen.dart';

class ExperienceDetailScreen extends ConsumerWidget {
  final AppUser trainee;
  final ExperienceModel experience;

  final bool canEdit;
  final bool canDelete;

  const ExperienceDetailScreen({
    super.key,
    required this.trainee,
    required this.experience,
    this.canEdit = false,
    this.canDelete = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "pending":
        return Colors.orange;

      case "rejected":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experienceAsync = ref.watch(
      experienceRecordProvider(
        ExperienceRecordParams(
          traineeId: trainee.uid,
          experienceId: experience.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Experience Details"),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditExperienceScreen(
                      trainee: trainee,
                      experience: experience,
                    ),
                  ),
                );
              },
            ),

          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Experience"),
                    content: const Text(
                      "Are you sure you want to delete this experience record?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                await ref
                    .read(experienceServiceProvider)
                    .deleteExperience(
                      trainee.uid,
                      experience.id,
                    );

                ref.invalidate(
                  experienceProvider(
                    ExperienceParams(
                      traineeId: trainee.uid,
                    ),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),

      body: experienceAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (record) {
          if (record == null) {
            return const Center(
              child: Text("Experience not found."),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Trainee"),
                  subtitle: Text(record.traineeName),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text("Session"),
                  subtitle: Text(record.sessionTitle),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text("Hours"),
                  subtitle: Text("${record.hours} hrs"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("Date"),
                  subtitle: Text(
                    "${record.date.day}/${record.date.month}/${record.date.year}",
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text("Location"),
                  subtitle: Text(record.location),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text("Coach"),
                  subtitle: Text(record.coachName),
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.verified,
                    color: _statusColor(record.status),
                  ),
                  title: const Text("Status"),
                  subtitle: Text(record.status),
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Coach Notes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        record.notes.isEmpty
                            ? "No notes"
                            : record.notes,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}