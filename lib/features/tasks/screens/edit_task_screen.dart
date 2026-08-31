import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/task_model.dart';

import '../providers/task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;
  final TaskModel task;

  const EditTaskScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
    required this.task,
  });

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _dueDate;

  late String _category;
  late String _status;

  late bool _autoVerify;
  late bool _coachReviewRequired;

  bool _saving = false;

  final categories = [
    "Technique",
    "Fitness",
    "Safety",
    "Assessment",
    "Theory",
    "Other",
  ];

  final statuses = [
    "Pending",
    "In Progress",
    "Completed",
  ];

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.task.title);

    _descriptionController =
        TextEditingController(text: widget.task.description);

    _dueDate = widget.task.dueDate;

    _category = widget.task.category;

    _status = widget.task.status;

    _autoVerify = widget.task.autoVerify;

    _coachReviewRequired =
        widget.task.coachReviewRequired;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      dueDate: _dueDate,
      status: _status,
      autoVerify: _autoVerify,
      coachReviewRequired: _coachReviewRequired,
    );

    try {
      await ref
          .read(taskServiceProvider)
          .updateTask(updatedTask);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task updated successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                      ? "Required"
                      : null,
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items: statuses
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),

            const SizedBox(height: 18),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Due Date"),
              subtitle: Text(
                "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const Divider(),

            SwitchListTile(
              title: const Text("Auto Verify"),
              value: _autoVerify,
              onChanged: (value) {
                setState(() {
                  _autoVerify = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Coach Review Required"),
              value: _coachReviewRequired,
              onChanged: (value) {
                setState(() {
                  _coachReviewRequired = value;
                });
              },
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _saving ? null : _updateTask,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _saving ? "Updating..." : "Update Task",
              ),
            ),
          ],
        ),
      ),
    );
  }
}