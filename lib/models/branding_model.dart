/// Per-organisation branding config — the concrete mechanism behind the
/// "white-label architecture" requirement. One document per org;
/// AppTheme reads this at startup (via BrandingProvider) to seed colors
/// and app name, so a new commercial licensee is a config change, not a
/// code change.
class OrgBranding {
  final String organisationId;
  final String appName;
  final String primaryColorHex; // e.g. '#1B4B6B'
  final String accentColorHex; // e.g. '#E8622C'
  final String? logoUrl;

  OrgBranding({
    required this.organisationId,
    required this.appName,
    required this.primaryColorHex,
    required this.accentColorHex,
    this.logoUrl,
  });

  factory OrgBranding.fromMap(String organisationId, Map<String, dynamic> map) {
    return OrgBranding(
      organisationId: organisationId,
      appName: map['appName'] ?? 'BASS Training',
      primaryColorHex: map['primaryColorHex'] ?? '#1B4B6B',
      accentColorHex: map['accentColorHex'] ?? '#E8622C',
      logoUrl: map['logoUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'appName': appName,
        'primaryColorHex': primaryColorHex,
        'accentColorHex': accentColorHex,
        'logoUrl': logoUrl,
      };

  static OrgBranding defaults(String organisationId) => OrgBranding(
        organisationId: organisationId,
        appName: 'BASS Training',
        primaryColorHex: '#1B4B6B',
        accentColorHex: '#E8622C',
      );

  OrgBranding copyWith({
    String? appName,
    String? primaryColorHex,
    String? accentColorHex,
    String? logoUrl,
  }) {
    return OrgBranding(
      organisationId: organisationId,
      appName: appName ?? this.appName,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
