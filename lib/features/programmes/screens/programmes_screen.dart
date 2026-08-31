import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/programme_provider.dart';
import '../widgets/programme_card.dart';
import 'create_programme_screen.dart';
import 'programme_detail_screen.dart';

class ProgrammesScreen extends ConsumerWidget {
  final bool canEdit;
  final bool canDelete;

  const ProgrammesScreen({
    super.key,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programmes = ref.watch(programmesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Programmes")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProgrammeScreen()),
          );
        },
      ),

      body: programmes.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },

        data: (programmeList) {
          if (programmeList.isEmpty) {
            return const Center(
              child: Text(
                "No Programmes Available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: programmeList.length,

            itemBuilder: (context, index) {
              final programme = programmeList[index];

              return ProgrammeCard(
                programme: programme,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgrammeDetailScreen(
                        programme: programme,
                        canEdit: canEdit,
                        canDelete: canDelete,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
