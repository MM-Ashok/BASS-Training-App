import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/experience_provider.dart';

class ExperienceProgressCard extends ConsumerWidget {
  final String traineeId;

  const ExperienceProgressCard({
    super.key,
    required this.traineeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvedAsync =
        ref.watch(approvedHoursProvider(traineeId));

    final remainingAsync =
        ref.watch(remainingHoursProvider(traineeId));

    final completionAsync =
        ref.watch(completionPercentageProvider(traineeId));

    return approvedAsync.when(
      loading: () => const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      error: (e, _) => Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(e.toString()),
        ),
      ),

      data: (approvedHours) {
        return remainingAsync.when(
          loading: () => const SizedBox(),

          error: (e, _) => Text(e.toString()),

          data: (remainingHours) {
            return completionAsync.when(
              loading: () => const SizedBox(),

              error: (e, _) => Text(e.toString()),

              data: (completion) {
                final completed = approvedHours >= 70;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "70-Hour Ski School Experience",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "${approvedHours.toStringAsFixed(1)} / 70 Hours",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),

                        const SizedBox(height: 16),

                        LinearProgressIndicator(
                          value: completion / 100,
                          minHeight: 10,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "${completion.toStringAsFixed(1)}% Completed",
                        ),

                        const Divider(height: 30),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _stat(
                              "Approved",
                              approvedHours.toStringAsFixed(1),
                              Colors.green,
                            ),

                            _stat(
                              "Remaining",
                              remainingHours.toStringAsFixed(1),
                              Colors.red,
                            ),
                          ],
                        ),

                        if (completed) ...[
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "🎉 70 Hours Completed",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _stat(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}