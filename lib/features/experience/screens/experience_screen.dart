import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../providers/experience_provider.dart';
import 'create_experience_screen.dart';
import 'experience_detail_screen.dart';
import '../widgets/experience_progress_card.dart';

class ExperienceScreen extends ConsumerWidget {
  final AppUser trainee;

  final bool canEdit;
  final bool canDelete;

  const ExperienceScreen({
    super.key,
    required this.trainee,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experienceAsync = ref.watch(
      experienceProvider(ExperienceParams(traineeId: trainee.uid)),
    );

    // final dashboardAsync = ref.watch(
    //   experienceDashboardProvider(
    //     ExperienceDashboardParams(traineeId: trainee.uid),
    //   ),
    // );

ExperienceProgressCard(
  traineeId: trainee.uid,
);
    

    final approvedHoursAsync = ref.watch(approvedHoursProvider(trainee.uid));

    final remainingHoursAsync = ref.watch(remainingHoursProvider(trainee.uid));

    final completionAsync = ref.watch(
      completionPercentageProvider(trainee.uid),
    );

    return Scaffold(
      appBar: AppBar(title: Text("${trainee.name} Experience")),

      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text("Add Experience"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateExperienceScreen(trainee: trainee),
                  ),
                );
              },
            )
          : null,

      body: Column(
        children: [
          /// =============================
          /// Progress Summary
          /// =============================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    approvedHoursAsync.when(
                      loading: () => const CircularProgressIndicator(),

                      error: (e, _) => Text(e.toString()),

                      data: (hours) => ListTile(
                        leading: const Icon(Icons.timer, color: Colors.blue),
                        title: const Text("Approved Hours"),
                        trailing: Text("${hours.toStringAsFixed(1)} hrs"),
                      ),
                    ),

                    remainingHoursAsync.when(
                      loading: () => const SizedBox(),

                      error: (_, __) => const SizedBox(),

                      data: (hours) => ListTile(
                        leading: const Icon(
                          Icons.hourglass_bottom,
                          color: Colors.orange,
                        ),
                        title: const Text("Remaining"),
                        trailing: Text("${hours.toStringAsFixed(1)} hrs"),
                      ),
                    ),

                    completionAsync.when(
                      loading: () => const SizedBox(),

                      error: (_, __) => const SizedBox(),

                      data: (percent) => Column(
                        children: [
                          LinearProgressIndicator(
                            value: percent / 100,
                            minHeight: 10,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${percent.toStringAsFixed(1)}% Complete",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// =============================
          /// Experience List
          /// =============================
          Expanded(
            child: experienceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text(e.toString())),

              data: (experience) {
                if (experience.isEmpty) {
                  return const Center(
                    child: Text("No experience records found."),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      experienceProvider(
                        ExperienceParams(traineeId: trainee.uid),
                      ),
                    );

                    ref.invalidate(approvedHoursProvider(trainee.uid));

                    ref.invalidate(remainingHoursProvider(trainee.uid));

                    ref.invalidate(completionPercentageProvider(trainee.uid));
                  },

                  child: ListView.builder(
                    itemCount: experience.length,

                    itemBuilder: (_, index) {
                      final record = experience[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(record.hours.toString()),
                          ),

                          title: Text(record.sessionTitle),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${record.hours} Hours"),

                              Text(record.location),

                              Text(
                                "${record.date.day}/${record.date.month}/${record.date.year}",
                              ),
                            ],
                          ),

                          trailing: const Icon(Icons.chevron_right),

                          onTap: () {
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExperienceDetailScreen(
                                  trainee: trainee,
                                  experience: record,
                                  canEdit: canEdit,
                                  canDelete: canDelete,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
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
