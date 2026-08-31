import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/programme_model.dart';
import '../../../data/models/phase_model.dart';
import '../providers/phase_provider.dart';

class CreatePhaseScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;

  const CreatePhaseScreen({
    super.key,
    required this.programme,
  });

  @override
  ConsumerState<CreatePhaseScreen> createState() =>
      _CreatePhaseScreenState();
}

class _CreatePhaseScreenState
    extends ConsumerState<CreatePhaseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderController = TextEditingController(text: "1");

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  String _status = "Draft";

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
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

  Future<void> _savePhase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final phase = PhaseModel(
        id: const Uuid().v4(),
        programmeId: widget.programme.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        order: int.parse(_orderController.text),
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        createdAt: DateTime.now(),
      );

      await ref.read(phaseServiceProvider).createPhase(phase);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phase created successfully."),
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
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Phase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.programme.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Phase Title",
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
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Phase Order",
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
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickStartDate,
              ),

              const Divider(),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("End Date"),
                subtitle: Text(_formatDate(_endDate)),
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
                  onPressed: _isSaving ? null : _savePhase,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Create Phase",
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