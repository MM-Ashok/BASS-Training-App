import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/task_model.dart';

import '../services/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;
  final SessionModel session;

  const CreateTaskScreen({
    super.key,
    required this.programme,
    required this.phase,
    required this.session,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final TaskService _taskService = TaskService();

  DateTime _dueDate = DateTime.now();

  String _category = "Technique";

  String _status = "Pending";

  bool _autoVerify = false;

  bool _coachReviewRequired = true;

  bool _isSaving = false;

  final List<String> _categories = [
    "Technique",
    "Fitness",
    "Safety",
    "Assessment",
    "Theory",
    "Other",
  ];

  final List<String> _statuses = [
    "Pending",
    "In Progress",
    "Completed",
  ];

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

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      final task = TaskModel(
        id: const Uuid().v4(),
        programmeId: widget.programme.id,
        phaseId: widget.phase.id,
        sessionId: widget.session.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        dueDate: _dueDate,
        status: _status,
        autoVerify: _autoVerify,
        coachReviewRequired: _coachReviewRequired,
        createdBy: user?.uid ?? "",
        assignedTo: "",
        createdAt: DateTime.now(),
      );

      await _taskService.createTask(task);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task created successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Task"),
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
                  value == null || value.isEmpty ? "Enter title" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Enter description" : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: _categories
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

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
              items: _statuses
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

            const SizedBox(height: 20),

            ListTile(
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
              onPressed: _isSaving ? null : _saveTask,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving ? "Saving..." : "Create Task",
              ),
            ),
          ],
        ),
      ),
    );
  }
}