import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/feedback_model.dart';
import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';

import '../providers/feedback_provider.dart';

class EditFeedbackScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;
  final FeedbackModel feedback;

  const EditFeedbackScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    required this.feedback,
  });

  @override
  ConsumerState<EditFeedbackScreen> createState() =>
      _EditFeedbackScreenState();
}

class _EditFeedbackScreenState
    extends ConsumerState<EditFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _feedbackController;

  bool _loading = false;

  late int _rating;

  late List<String> _selectedSkills;

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
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.feedback.title);

    _feedbackController =
        TextEditingController(text: widget.feedback.feedback);

    _rating = widget.feedback.rating;

    _selectedSkills =
        List<String>.from(widget.feedback.skills);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _updateFeedback() async {
    if (!_formKey.currentState!.validate()) return;

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

    setState(() => _loading = true);

    try {
      final updated = widget.feedback.copyWith(
        title: _titleController.text.trim(),
        feedback: _feedbackController.text.trim(),
        rating: _rating,
        skills: _selectedSkills,
      );

      await ref
          .read(feedbackServiceProvider)
          .updateFeedback(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback updated successfully."),
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
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Feedback"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            TextFormField(
              initialValue: widget.feedback.traineeName,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Trainee",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

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

            TextFormField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Feedback",
                border: OutlineInputBorder(),
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

            const SizedBox(height: 20),

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
                return FilterChip(
                  label: Text(skill),
                  selected: _selectedSkills.contains(skill),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (!_selectedSkills.contains(skill)) {
                          _selectedSkills.add(skill);
                        }
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
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  _loading ? "Updating..." : "Update Feedback",
                ),
                onPressed: _loading ? null : _updateFeedback,
              ),
            ),
          ],
        ),
      ),
    );
  }
}