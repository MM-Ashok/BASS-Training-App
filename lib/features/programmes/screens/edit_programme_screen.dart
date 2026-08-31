import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../providers/programme_provider.dart';

class EditProgrammeScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;

  const EditProgrammeScreen({
    super.key,
    required this.programme,
  });

  @override
  ConsumerState<EditProgrammeScreen> createState() =>
      _EditProgrammeScreenState();
}

class _EditProgrammeScreenState
    extends ConsumerState<EditProgrammeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _seasonController;

  late DateTime _startDate;
  late DateTime _endDate;

  late String _status;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.programme.name);

    _descriptionController =
        TextEditingController(text: widget.programme.description);

    _seasonController =
        TextEditingController(text: widget.programme.season);

    _startDate = widget.programme.startDate;
    _endDate = widget.programme.endDate;
    _status = widget.programme.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _updateProgramme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProgramme = widget.programme.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        season: _seasonController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
      );

      await ref
          .read(programmeServiceProvider)
          .updateProgramme(updatedProgramme);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Programme updated successfully."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Programme"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Programme Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Required"
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _seasonController,
                decoration: const InputDecoration(
                  labelText: "Season",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Required"
                        : null,
              ),

              const SizedBox(height: 20),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Start Date"),
                subtitle: Text(formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickStartDate,
              ),

              const Divider(),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("End Date"),
                subtitle: Text(formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickEndDate,
              ),

              const Divider(),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Status",
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Draft",
                    child: Text("Draft"),
                  ),
                  DropdownMenuItem(
                    value: "Active",
                    child: Text("Active"),
                  ),
                  DropdownMenuItem(
                    value: "Completed",
                    child: Text("Completed"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      _isSaving ? null : _updateProgramme,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Update Programme",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}