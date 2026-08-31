import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/experience_model.dart';

import '../../authentication/providers/user_provider.dart';
import '../providers/experience_provider.dart';

class CreateExperienceScreen extends ConsumerStatefulWidget {
  final AppUser? trainee;

  const CreateExperienceScreen({super.key, this.trainee});

  @override
  ConsumerState<CreateExperienceScreen> createState() =>
      _CreateExperienceScreenState();
}

class _CreateExperienceScreenState
    extends ConsumerState<CreateExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _hoursController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _sessionTitleController = TextEditingController();

  AppUser? _selectedTrainee;

  DateTime _selectedDate = DateTime.now();

  String _status = "Pending";

  bool _loading = false;

  final List<String> _statuses = ["Pending", "Approved", "Rejected"];

  @override
  void initState() {
    super.initState();

    _selectedTrainee = widget.trainee;
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _sessionTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final traineesAsync = ref.watch(traineesProvider(""));

    return Scaffold(
      appBar: AppBar(title: const Text("Add Experience")),

      body: traineesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (trainees) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.trainee == null)
                  DropdownButtonFormField<AppUser>(
                    value: _selectedTrainee,
                    decoration: const InputDecoration(
                      labelText: "Trainee",
                      border: OutlineInputBorder(),
                    ),
                    items: trainees
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTrainee = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Select trainee";
                      }
                      return null;
                    },
                  ),

                if (widget.trainee != null)
                  TextFormField(
                    initialValue: widget.trainee!.name,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Trainee",
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _sessionTitleController,
                  decoration: const InputDecoration(
                    labelText: "Session Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter session title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _hoursController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Hours",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter hours";
                    }

                    if (double.tryParse(value) == null) {
                      return "Invalid number";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Coach Notes",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(),
                  ),
                  title: const Text("Experience Date"),
                  subtitle: Text(
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(_loading ? "Saving..." : "Save Experience"),
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            if (_selectedTrainee == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select a trainee."),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _loading = true;
                            });

                            try {
                              final user = FirebaseAuth.instance.currentUser!;

                              final experience = ExperienceModel(
                                id: const Uuid().v4(),

                                traineeId: _selectedTrainee!.uid,
                                traineeName: _selectedTrainee!.name,

                                // If your session is already known,
                                // replace these empty values later.
                                programmeId: _selectedTrainee!.programmeId,
                                phaseId: "",
                                sessionId: "",

                                sessionTitle: _sessionTitleController.text
                                    .trim(),

                                coachId: user.uid,
                                coachName: user.displayName ?? user.email ?? "",

                                date: _selectedDate,

                                hours: double.parse(_hoursController.text),

                                location: _locationController.text.trim(),

                                notes: _notesController.text.trim(),

                                status: _status,

                                createdAt: DateTime.now(),
                              );

                              await ref
                                  .read(experienceServiceProvider)
                                  .createExperience(experience);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Experience added successfully.",
                                  ),
                                ),
                              );

                              Navigator.pop(context);
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _loading = false;
                                });
                              }
                            }
                          },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
