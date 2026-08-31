import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/attendance_provider.dart';

class MyAttendanceScreen extends ConsumerWidget {
  const MyAttendanceScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Colors.green;

      case "late":
        return Colors.orange;

      case "excused":
        return Colors.blue;

      case "absent":
      default:
        return Colors.red;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Icons.check_circle;

      case "late":
        return Icons.access_time;

      case "excused":
        return Icons.info;

      case "absent":
      default:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(myAttendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Attendance"),
      ),
      body: attendanceAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (attendance) {
          if (attendance.isEmpty) {
            return const Center(
              child: Text(
                "No attendance records found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final present = attendance
              .where((e) => e.status.toLowerCase() == "present")
              .length;

          final percentage =
              ((present / attendance.length) * 100).round();

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fact_check,
                        color: Colors.blue,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Attendance\n$percentage%",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "$present/${attendance.length}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(myAttendanceProvider);
                  },
                  child: ListView.builder(
                    itemCount: attendance.length,
                    itemBuilder: (_, index) {
                      final record = attendance[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _statusColor(record.status),
                            child: Icon(
                              _statusIcon(record.status),
                              color: Colors.white,
                            ),
                          ),

                          title: Text(record.status),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${record.markedAt.day}/${record.markedAt.month}/${record.markedAt.year}",
                              ),

                              if (record.notes.isNotEmpty)
                                Text(
                                  record.notes,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),

                          trailing: record.checkInTime != null
                              ? Text(
                                  "${record.checkInTime!.hour.toString().padLeft(2, '0')}:${record.checkInTime!.minute.toString().padLeft(2, '0')}",
                                )
                              : const Text("--"),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}