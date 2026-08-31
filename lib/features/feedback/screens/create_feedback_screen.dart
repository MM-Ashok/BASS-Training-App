import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/feedback_model.dart';

import '../../authentication/providers/user_provider.dart';
import '../providers/feedback_provider.dart';

class CreateFeedbackScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  const CreateFeedbackScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
  });

  @override
  ConsumerState<CreateFeedbackScreen> createState() =>
      _CreateFeedbackScreenState();
}

class _CreateFeedbackScreenState
    extends ConsumerState<CreateFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _feedbackController = TextEditingController();

  bool _loading = false;

  AppUser? _selectedTrainee;

  int _rating = 3;

  final List<String> _selectedSkills = [];

  final List<String> _skills = [
    "Balance",
    "Edge Control",
    "Turning",
    "Carving",
    "Pole Plant",
    "Parallel Turns",
    "Snowplough",
    "Speed Control",
    "Confidence",
    "Safety Awareness",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final traineesAsync = ref.watch(
      traineesProvider(widget.programme.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Feedback"),
      ),
      body: traineesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (trainees) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                /// Trainee Dropdown
                DropdownButtonFormField<AppUser>(
                  value: _selectedTrainee,
                  decoration: const InputDecoration(
                    labelText: "Select Trainee",
                    border: OutlineInputBorder(),
                  ),
                  items: trainees.map((trainee) {
                    return DropdownMenuItem(
                      value: trainee,
                      child: Text(trainee.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTrainee = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select trainee";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Feedback Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Feedback Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter feedback title";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Feedback
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Feedback",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter feedback";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                const Text(
                  "Rating",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: List.generate(5, (index) {
                    final value = index + 1;

                    return IconButton(
                      iconSize: 34,
                      color: Colors.amber,
                      onPressed: () {
                        setState(() {
                          _rating = value;
                        });
                      },
                      icon: Icon(
                        value <= _rating
                            ? Icons.star
                            : Icons.star_border,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Skills",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    final selected =
                        _selectedSkills.contains(skill);

                    return FilterChip(
                      label: Text(skill),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedSkills.add(skill);
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),
                                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(
                      _loading ? "Saving..." : "Save Feedback",
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            if (_selectedSkills.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select at least one skill.",
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _loading = true;
                            });

                            try {
                              final user =
                                  FirebaseAuth.instance.currentUser!;

                              final feedback = FeedbackModel(
                                id: const Uuid().v4(),

                                programmeId: widget.programme.id,
                                phaseId: widget.phase.id,
                                sessionId: widget.session.id,

                                traineeId: _selectedTrainee!.uid,
                                traineeName: _selectedTrainee!.name,

                                coachId: user.uid,

                                // Replace later with logged-in coach's name
                                coachName:
                                    user.displayName ?? user.email ?? "",

                                title: _titleController.text.trim(),

                                feedback: _feedbackController.text.trim(),

                                rating: _rating,

                                skills: _selectedSkills,

                                createdAt: DateTime.now(),
                              );

                              await ref
                                  .read(feedbackServiceProvider)
                                  .createFeedback(feedback);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Feedback saved successfully.",
                                  ),
                                ),
                              );

                              Navigator.pop(context);
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                  ),
                                ),
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