import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  String _gender = "";
  DateTime? _dob;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.user.name);

    _phoneController =
        TextEditingController(text: widget.user.phone);

    _gender = widget.user.gender;
    _dob = widget.user.dob;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _save() async {
    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _gender,
      dob: _dob,
    );

    try {
      await ref
          .read(profileControllerProvider)
          .updateProfile(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully."),
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
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(profileLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            enabled: false,
            controller: TextEditingController(
              text: widget.user.email,
            ),
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone",
              prefixIcon: Icon(Icons.phone),
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _gender.isEmpty ? null : _gender,
            decoration: const InputDecoration(
              labelText: "Gender",
              prefixIcon: Icon(Icons.people),
            ),
            items: const [
              DropdownMenuItem(
                value: "Male",
                child: Text("Male"),
              ),
              DropdownMenuItem(
                value: "Female",
                child: Text("Female"),
              ),
              DropdownMenuItem(
                value: "Other",
                child: Text("Other"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _gender = value ?? "";
              });
            },
          ),

          const SizedBox(height: 20),

          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey),
            ),
            leading: const Icon(Icons.cake),
            title: const Text("Date of Birth"),
            subtitle: Text(
              _dob == null
                  ? "Select Date"
                  : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),

          const SizedBox(height: 20),

          TextField(
            enabled: false,
            controller: TextEditingController(
              text: widget.user.role,
            ),
            decoration: const InputDecoration(
              labelText: "Role",
              prefixIcon: Icon(Icons.badge),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            enabled: false,
            controller: TextEditingController(
              text: widget.user.programmeId,
            ),
            decoration: const InputDecoration(
              labelText: "Programme",
              prefixIcon: Icon(Icons.school),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: loading ? null : _save,
              icon: const Icon(Icons.save),
              label: loading
                  ? const CircularProgressIndicator()
                  : const Text("Save Changes"),
            ),
          ),
        ],
      ),
    );
  }
}