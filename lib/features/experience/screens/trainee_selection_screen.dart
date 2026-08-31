import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../../authentication/providers/user_provider.dart';
import 'experience_screen.dart';

class TraineeSelectionScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  const TraineeSelectionScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
  });

  @override
  ConsumerState<TraineeSelectionScreen> createState() =>
      _TraineeSelectionScreenState();
}

class _TraineeSelectionScreenState
    extends ConsumerState<TraineeSelectionScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final traineesAsync = ref.watch(
      traineesProvider(widget.programme.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Trainee"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search trainee...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = "";
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: traineesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (e, _) => Center(
                child: Text(e.toString()),
              ),

              data: (trainees) {
                final filtered = trainees.where((trainee) {
                  return trainee.name
                      .toLowerCase()
                      .contains(_searchText);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No trainees found."),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final trainee = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              trainee.photoUrl.isNotEmpty
                                  ? NetworkImage(
                                      trainee.photoUrl,
                                    )
                                  : null,
                          child: trainee.photoUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),

                        title: Text(trainee.name),

                        subtitle: Text(
                          trainee.email,
                        ),

                        trailing: const Icon(
                          Icons.chevron_right,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExperienceScreen(
                                trainee: trainee,
                                canEdit: true,
                                canDelete: true,
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
          ),
        ],
      ),
    );
  }
}