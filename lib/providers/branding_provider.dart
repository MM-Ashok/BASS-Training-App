import 'package:flutter/material.dart';
import '../models/branding_model.dart';
import '../services/branding_service.dart';

class BrandingProvider extends ChangeNotifier {
  final BrandingService _service = BrandingService();
  OrgBranding? branding;
  bool isLoading = false;

  Future<void> load(String organisationId) async {
    isLoading = true;
    notifyListeners();
    branding = await _service.getBranding(organisationId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(OrgBranding updated) async {
    await _service.saveBranding(updated);
    branding = updated;
    notifyListeners();
  }

  Color get primaryColor => branding != null ? hexToColorPublic(branding!.primaryColorHex) : const Color(0xFF1B4B6B);
  Color get accentColor => branding != null ? hexToColorPublic(branding!.accentColorHex) : const Color(0xFFE8622C);
  String get appName => branding?.appName ?? 'BASS Training';

  static Color hexToColorPublic(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : const Color(0xFF1B4B6B);
  }
}
