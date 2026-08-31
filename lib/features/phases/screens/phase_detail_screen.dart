import 'package:flutter/material.dart';

import '../../../data/models/phase_model.dart';
import '../../../data/models/programme_model.dart';
import 'edit_phase_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/phase_provider.dart';
import '../../sessions/screens/sessions_screen.dart';

class PhaseDetailScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final bool canEdit;
  final bool canDelete;

  const PhaseDetailScreen({
    super.key,
    required this.programme,
    required this.phase,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phaseAsync = ref.watch(
      phaseProvider(PhaseParams(programmeId: programme.id, phaseId: phase.id)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(phase.title),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditPhaseScreen(programme: programme, phase: phase),
                  ),
                );

                // Navigator.pop(context);
              },
            ),

          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Phase"),
                    content: const Text(
                      "Are you sure you want to delete this phase?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                try {
                  await ref
                      .read(phaseServiceProvider)
                      .deletePhase(programme.id, phase.id);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Phase deleted successfully."),
                    ),
                  );

                  // Close Detail Screen
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
        ],
      ),
      body: phaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text(e.toString())),

        data: (updatedPhase) {
          if (updatedPhase == null) {
            return const Center(child: Text("Phase not found"));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _infoTile("Programme", programme.name),

              _infoTile("Title", updatedPhase.title),

              _infoTile("Description", updatedPhase.description),

              _infoTile("Order", updatedPhase.order.toString()),

              _infoTile("Status", updatedPhase.status),

              _infoTile("Start Date", _formatDate(updatedPhase.startDate)),

              _infoTile("End Date", _formatDate(updatedPhase.endDate)),
              const SizedBox(height: 30),

              FilledButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text("Manage Sessions"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionsScreen(
                        programme: programme,
                        phase: updatedPhase,
                        canEdit: canEdit,
                        canDelete: canDelete,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
