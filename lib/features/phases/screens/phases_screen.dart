import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../providers/phase_provider.dart';
import 'create_phase_screen.dart';
import 'phase_detail_screen.dart';

class PhasesScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final bool canEdit;
  final bool canDelete;

  const PhasesScreen({
    super.key,
    required this.programme,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phasesAsync = ref.watch(phasesProvider(programme.id));

    return Scaffold(
      appBar: AppBar(
        title: Text("${programme.name} Phases"),
      ),

      floatingActionButton: canEdit
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePhaseScreen(
                      programme: programme,
                    ),
                  ),
                );
              },
            )
          : null,

      body: phasesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),

        data: (phases) {
          if (phases.isEmpty) {
            return const Center(
              child: Text(
                "No phases created yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: phases.length,
            itemBuilder: (context, index) {
              final PhaseModel phase = phases[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),

                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      phase.order.toString(),
                    ),
                  ),

                  title: Text(
                    phase.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      Text(phase.description),

                      const SizedBox(height: 6),

                      Text(
                        "Status: ${phase.status}",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhaseDetailScreen(
                          programme: programme,
                          phase: phase,
                          canEdit: canEdit,
                          canDelete: canDelete,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}