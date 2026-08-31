import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';

import '../providers/session_provider.dart';
import 'create_session_screen.dart';
import 'session_detail_screen.dart';

class SessionsScreen extends ConsumerWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;

  final bool canEdit;
  final bool canDelete;

  const SessionsScreen({
    super.key,
    required this.programme,
    required this.phase,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(
      sessionsProvider(
        SessionParams(
          programmeId: programme.id,
          phaseId: phase.id,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("${phase.title} Sessions"),
      ),

      floatingActionButton: canEdit
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateSessionScreen(
                      programme: programme,
                      phase: phase,
                    ),
                  ),
                );
              },
            )
          : null,

      body: sessionsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                "No sessions created yet.",
              ),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      "${index + 1}",
                    ),
                  ),

                  title: Text(session.title),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(session.coachName),

                      Text(
                        "${session.date.day}/${session.date.month}/${session.date.year}",
                      ),

                      Text(session.status),
                    ],
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(
                          programme: programme,
                          phase: phase,
                          session: session,
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