import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/phase_model.dart';
import '../../../data/models/programme_model.dart';
import '../providers/phase_provider.dart';

class EditPhaseScreen extends ConsumerStatefulWidget {
  final ProgrammeModel programme;
  final PhaseModel phase;

  const EditPhaseScreen({
    super.key,
    required this.programme,
    required this.phase,
  });

  @override
  ConsumerState<EditPhaseScreen> createState() => _EditPhaseScreenState();
}

class _EditPhaseScreenState extends ConsumerState<EditPhaseScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _orderController;

  late DateTime _startDate;
  late DateTime _endDate;

  late String _status;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.phase.title);

    _descriptionController =
        TextEditingController(text: widget.phase.description);

    _orderController =
        TextEditingController(text: widget.phase.order.toString());

    _startDate = widget.phase.startDate;
    _endDate = widget.phase.endDate;
    _status = widget.phase.status;
  }

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
      setState(() => _startDate = picked);
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
      setState(() => _endDate = picked);
    }
  }

  Future<void> _updatePhase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedPhase = widget.phase.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        order: int.parse(_orderController.text),
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
      );

      await ref
          .read(phaseServiceProvider)
          .updatePhase(updatedPhase);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phase updated successfully."),
        ),
      );

      Navigator.pop(context, updatedPhase);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Phase"),
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
                  labelText: "Order",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                title: const Text("Start Date"),
                subtitle: Text(formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickStartDate,
              ),

              const Divider(),

              ListTile(
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
                  onPressed: _isSaving ? null : _updatePhase,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Update Phase",
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