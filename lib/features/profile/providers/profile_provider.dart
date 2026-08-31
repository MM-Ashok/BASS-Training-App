import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../data/models/app_user.dart';
import '../services/profile_service.dart';

/// ======================================================
/// Profile Service
/// ======================================================

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// ======================================================
/// Current Logged-in User Profile
/// ======================================================

final currentProfileProvider =
    StreamProvider<AppUser?>((ref) {
  return ref
      .read(profileServiceProvider)
      .getCurrentUserStream();
});

/// ======================================================
/// Profile Update State
/// ======================================================

class ProfileLoadingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setLoading(bool value) {
    state = value;
  }
}

final profileLoadingProvider =
    NotifierProvider<ProfileLoadingNotifier, bool>(
  ProfileLoadingNotifier.new,
);

/// ======================================================
/// Profile Controller
/// ======================================================

final profileControllerProvider =
    Provider((ref) {
  return ProfileController(ref);
});

class ProfileController {
  final Ref ref;

  ProfileController(this.ref);

  Future<void> updateProfile(
    AppUser user,
  ) async {
    ref.read(profileLoadingProvider.notifier).state = true;

    try {
      await ref
          .read(profileServiceProvider)
          .updateProfile(user);
    } finally {
      ref.read(profileLoadingProvider.notifier).state = false;
    }
  }

  Future<void> updatePhoto(
    String uid,
    String photoUrl,
  ) async {
    await ref
        .read(profileServiceProvider)
        .updatePhotoUrl(uid, photoUrl);
  }

  Future<void> logout() async {
    await ref
        .read(profileServiceProvider)
        .logout();
  }

  Future<void> changePassword(
    String password,
  ) async {
    await ref
        .read(profileServiceProvider)
        .changePassword(password);
  }
}