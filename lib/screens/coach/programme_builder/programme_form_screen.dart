import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/programme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/programme_model.dart';

/// Handles both create and edit — pass [existing] to edit.
class ProgrammeFormScreen extends StatefulWidget {
  final Programme? existing;
  const ProgrammeFormScreen({super.key, this.existing});

  @override
  State<ProgrammeFormScreen> createState() => _ProgrammeFormScreenState();
}

class _ProgrammeFormScreenState extends State<ProgrammeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 120));
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _startDate = p.startDate;
      _endDate = p.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<ProgrammeProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id ?? 'demo-head-coach';

    if (_isEditing) {
      await provider.updateProgramme(widget.existing!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      ));
    } else {
      await provider.createProgramme(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        headCoachId: userId,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Programme' : 'New Programme')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Programme Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Start Date',
                    date: _startDate,
                    formatted: dateFmt.format(_startDate),
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerTile(
                    label: 'End Date',
                    date: _endDate,
                    formatted: dateFmt.format(_endDate),
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'Save Changes' : 'Create Programme'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final String formatted;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.formatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(formatted),
      ),
    );
  }
}
