import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/programme_provider.dart';
import '../../../models/programme_model.dart';
import '../../../utils/theme.dart';
import 'phase_form_dialog.dart';
import 'session_list_screen.dart';

class PhaseListScreen extends StatelessWidget {
  final Programme programme;
  const PhaseListScreen({super.key, required this.programme});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgrammeProvider>();
    final dateFmt = DateFormat('MMM d');

    return Scaffold(
      appBar: AppBar(title: Text(programme.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => PhaseFormDialog(programmeId: programme.id),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Phase'),
      ),
      body: provider.phases.isEmpty
          ? Center(
              child: Text('No phases yet — build your season structure',
                  style: TextStyle(color: Colors.grey[600])),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.phases.length,
              onReorder: (oldIndex, newIndex) {
                final list = List<Phase>.from(provider.phases);
                if (newIndex > oldIndex) newIndex -= 1;
                final item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
                context.read<ProgrammeProvider>().reorderPhases(list);
              },
              itemBuilder: (context, i) {
                final phase = provider.phases[i];
                final sessionCount = provider.sessionsForPhase(phase.id).length;
                return Card(
                  key: ValueKey(phase.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text('${i + 1}', style: const TextStyle(color: AppTheme.primary)),
                    ),
                    title: Text(phase.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${dateFmt.format(phase.startDate)} – ${dateFmt.format(phase.endDate)} · '
                      '$sessionCount session${sessionCount == 1 ? '' : 's'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                PhaseFormDialog(programmeId: programme.id, existing: phase),
                          );
                        } else if (value == 'delete') {
                          await context
                              .read<ProgrammeProvider>()
                              .deletePhase(programme.id, phase.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SessionListScreen(programme: programme, phase: phase),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
