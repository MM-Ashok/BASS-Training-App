import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/programme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/programme_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme.dart';
import 'programme_form_screen.dart';
import 'phase_list_screen.dart';

class ProgrammeListScreen extends StatefulWidget {
  const ProgrammeListScreen({super.key});

  @override
  State<ProgrammeListScreen> createState() => _ProgrammeListScreenState();
}

class _ProgrammeListScreenState extends State<ProgrammeListScreen> {
  @override
  void initState() {
    super.initState();
    // Uses demoOrganisationId as a stand-in for auth.currentUser.organisationId
    // until Firebase auth is wired up to a real org during the build phase.
    final orgId = context.read<AuthProvider>().currentUser?.organisationId ??
        AppConstants.demoOrganisationId;
    context.read<ProgrammeProvider>().init(orgId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgrammeProvider>();
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Programmes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProgrammeFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Programme'),
      ),
      body: provider.programmes.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.programmes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final Programme p = provider.programmes[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${dateFmt.format(p.startDate)} — ${dateFmt.format(p.endDate)}\n'
                        '${p.coachIds.length} coaches · ${p.traineeIds.length} trainees',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ProgrammeFormScreen(existing: p)));
                        } else if (value == 'delete') {
                          final confirm = await _confirmDelete(context, p.title);
                          if (confirm == true) {
                            await context.read<ProgrammeProvider>().deleteProgramme(p.id);
                          }
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () {
                      context.read<ProgrammeProvider>().selectProgramme(p.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PhaseListScreen(programme: p)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete programme?'),
        content: Text('This will permanently delete "$title" and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_view_month, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No programmes yet', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text('Tap "New Programme" to build your first season',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}
