import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/experience_model.dart';
import '../providers/experience_provider.dart';

class EditExperienceScreen extends ConsumerStatefulWidget {
  final AppUser trainee;
  final ExperienceModel experience;

  const EditExperienceScreen({
    super.key,
    required this.trainee,
    required this.experience,
  });

  @override
  ConsumerState<EditExperienceScreen> createState() =>
      _EditExperienceScreenState();
}

class _EditExperienceScreenState
    extends ConsumerState<EditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _sessionTitleController;
  late TextEditingController _hoursController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late String _status;

  bool _loading = false;

  final List<String> _statuses = [
    "Pending",
    "Approved",
    "Rejected",
  ];

  @override
  void initState() {
    super.initState();

    _sessionTitleController =
        TextEditingController(text: widget.experience.sessionTitle);

    _hoursController =
        TextEditingController(text: widget.experience.hours.toString());

    _locationController =
        TextEditingController(text: widget.experience.location);

    _notesController =
        TextEditingController(text: widget.experience.notes);

    _selectedDate = widget.experience.date;
    _status = widget.experience.status;
  }

  @override
  void dispose() {
    _sessionTitleController.dispose();
    _hoursController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateExperience() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updated = widget.experience.copyWith(
        sessionTitle: _sessionTitleController.text.trim(),
        hours: double.parse(_hoursController.text),
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        date: _selectedDate,
        status: _status,
      );

      await ref
          .read(experienceServiceProvider)
          .updateExperience(updated);

      ref.invalidate(
        experienceProvider(
          ExperienceParams(
            traineeId: widget.trainee.uid,
          ),
        ),
      );

      ref.invalidate(
        experienceRecordProvider(
          ExperienceRecordParams(
            traineeId: widget.trainee.uid,
            experienceId: widget.experience.id,
          ),
        ),
      );

      ref.invalidate(
        approvedHoursProvider(widget.trainee.uid),
      );

      ref.invalidate(
        remainingHoursProvider(widget.trainee.uid),
      );

      ref.invalidate(
        completionPercentageProvider(widget.trainee.uid),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Experience updated successfully."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
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
        title: const Text("Edit Experience"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: widget.trainee.name,
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Hours",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter hours";
                }

                if (double.tryParse(value) == null) {
                  return "Invalid hours";
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
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  _loading
                      ? "Updating..."
                      : "Update Experience",
                ),
                onPressed:
                    _loading ? null : _updateExperience,
              ),
            ),
          ],
        ),
      ),
    );
  }
}