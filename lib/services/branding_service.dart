import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branding_model.dart';

/// Reads/writes the per-org branding doc at organisations/{orgId}
/// (top-level fields alongside the org's users/programmes subcollections).
class BrandingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<OrgBranding> getBranding(String orgId) async {
    final doc = await _db.doc('organisations/$orgId').get();
    if (!doc.exists || doc.data()?['branding'] == null) {
      return OrgBranding.defaults(orgId);
    }
    return OrgBranding.fromMap(orgId, Map<String, dynamic>.from(doc.data()!['branding']));
  }

  Future<void> saveBranding(OrgBranding branding) {
    return _db.doc('organisations/${branding.organisationId}').set(
      {'branding': branding.toMap()},
      SetOptions(merge: true),
    );
  }

  Stream<OrgBranding> watchBranding(String orgId) {
    return _db.doc('organisations/$orgId').snapshots().map((doc) {
      if (!doc.exists || doc.data()?['branding'] == null) {
        return OrgBranding.defaults(orgId);
      }
      return OrgBranding.fromMap(orgId, Map<String, dynamic>.from(doc.data()!['branding']));
    });
  }
}
