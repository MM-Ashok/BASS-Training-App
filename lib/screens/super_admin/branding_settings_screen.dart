import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/branding_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/branding_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

/// The configuration screen behind the "white-label architecture"
/// requirement — org name, primary/accent colors, and logo URL are
/// stored in Firestore per-organisation and read back by BrandingProvider
/// at app startup, so a new commercial licensee is a data change here,
/// not a code change or new app build.
class BrandingSettingsScreen extends StatefulWidget {
  const BrandingSettingsScreen({super.key});

  @override
  State<BrandingSettingsScreen> createState() => _BrandingSettingsScreenState();
}

class _BrandingSettingsScreenState extends State<BrandingSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _primaryController;
  late TextEditingController _accentController;
  late TextEditingController _logoController;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orgId = auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    final branding = context.watch<BrandingProvider>();

    if (!_initialized) {
      if (branding.branding == null && !branding.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) => branding.load(orgId));
      }
      final b = branding.branding ?? OrgBranding.defaults(orgId);
      _nameController = TextEditingController(text: b.appName);
      _primaryController = TextEditingController(text: b.primaryColorHex);
      _accentController = TextEditingController(text: b.accentColorHex);
      _logoController = TextEditingController(text: b.logoUrl ?? '');
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('White-Label Branding')),
      body: branding.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'These settings control the app name and colors shown to '
                  'everyone in this organisation — the mechanism behind '
                  'future white-label licensing.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'App / Organisation Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _primaryController,
                  decoration: const InputDecoration(
                    labelText: 'Primary Color (hex)',
                    hintText: '#1B4B6B',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _accentController,
                  decoration: const InputDecoration(
                    labelText: 'Accent Color (hex)',
                    hintText: '#E8622C',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _logoController,
                  decoration: const InputDecoration(labelText: 'Logo URL (optional)'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _ColorSwatch(hex: _primaryController.text, label: 'Primary'),
                    const SizedBox(width: 12),
                    _ColorSwatch(hex: _accentController.text, label: 'Accent'),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await branding.save(OrgBranding(
                      organisationId: orgId,
                      appName: _nameController.text.trim(),
                      primaryColorHex: _primaryController.text.trim(),
                      accentColorHex: _accentController.text.trim(),
                      logoUrl: _logoController.text.trim().isEmpty
                          ? null
                          : _logoController.text.trim(),
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Branding saved')));
                    }
                  },
                  child: const Text('Save Branding'),
                ),
              ],
            ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String hex;
  final String label;
  const _ColorSwatch({required this.hex, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = BrandingProvider.hexToColorPublic(hex);
    } catch (_) {
      color = AppTheme.primary;
    }
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
