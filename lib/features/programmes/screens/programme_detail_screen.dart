import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../providers/programme_provider.dart';
import 'edit_programme_screen.dart';
import '../../phases/screens/phases_screen.dart';

class ProgrammeDetailScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final bool canEdit;
  final bool canDelete;

  const ProgrammeDetailScreen({
    super.key,
    required this.programme,
    this.canEdit = false,
    this.canDelete = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(programme.name),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProgrammeScreen(programme: programme),
                  ),
                );
              },
            ),

          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Programme"),
                    content: const Text(
                      "Are you sure you want to delete this programme?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(programmeServiceProvider)
                      .deleteProgramme(programme.id);

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Programme deleted")),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programme.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Chip(
                    backgroundColor: _statusColor(programme.status),
                    label: Text(
                      programme.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(programme.description),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text("Season: ${programme.season}"),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 8),
                      Text(
                        "${programme.startDate.day}/${programme.startDate.month}/${programme.startDate.year}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.event),
                      const SizedBox(width: 8),
                      Text(
                        "${programme.endDate.day}/${programme.endDate.month}/${programme.endDate.year}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            icon: const Icon(Icons.layers),
            label: const Text("Manage Phases"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhasesScreen(
                    programme: programme,
                    canEdit: canEdit,
                    canDelete: canDelete,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
