import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../services/user_service.dart';

/// ======================================================
/// User Service Provider
/// ======================================================

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// ======================================================
/// Current Logged-in User
/// ======================================================

final currentUserProvider = FutureProvider<AppUser?>((ref) {
  return ref.read(userServiceProvider).getCurrentUser();
});

/// ======================================================
/// All Users
/// ======================================================

final usersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.read(userServiceProvider).getUsers();
});

/// ======================================================
/// Users By Role
/// ======================================================

final usersByRoleProvider =
    StreamProvider.family<List<AppUser>, String>((ref, role) {
  return ref.read(userServiceProvider).getUsersByRole(role);
});

/// ======================================================
/// Single User
/// ======================================================

final userProvider =
    StreamProvider.family<AppUser?, String>((ref, uid) {
  return ref.read(userServiceProvider).getUser(uid);
});

/// ======================================================
/// Dashboard Count Providers
/// ======================================================

// final totalUsersProvider = StreamProvider<int>((ref) {
//   return ref.watch(usersProvider.stream).map((users) => users.length);
// });

// final coachesProvider = StreamProvider<int>((ref) {
//   return ref
//       .watch(usersByRoleProvider("Coach").stream)
//       .map((users) => users.length);
// });

// final traineesProvider = StreamProvider<int>((ref) {
//   return ref
//       .watch(usersByRoleProvider("Trainee").stream)
//       .map((users) => users.length);
// });

// final headCoachesProvider = StreamProvider<int>((ref) {
//   return ref
//       .watch(usersByRoleProvider("Head Coach").stream)
//       .map((users) => users.length);
// });



final traineesProvider =
    StreamProvider.family<List<AppUser>, String>((ref, programmeId) {
  return ref.read(userServiceProvider).getTrainees(programmeId);
});