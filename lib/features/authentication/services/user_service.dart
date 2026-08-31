import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

    final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'active': true,
      'programmeId': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;

    print("Current User UID: ${user?.uid}");

    if (user == null) {
      print("Current user is null");
      return null;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    print("Document exists: ${doc.exists}");

    if (doc.exists) {
      print(doc.data());
    }

    if (!doc.exists) {
      return null;
    }

    return AppUser.fromMap(doc.id, doc.data()!);
  }

  // ============================================================
  // User Management
  // ============================================================

  /// Live list of all users
  Stream<List<AppUser>> getUsers() {
    return _users.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Filter users by role
  Stream<List<AppUser>> getUsersByRole(String role) {
    return _users
        .where('role', isEqualTo: role)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

Stream<List<AppUser>> getTrainees(String programmeId) {
  return _firestore
      .collection('users')
      .where('role', isEqualTo: 'trainee')
      .where('programmeId', isEqualTo: programmeId)
      .where('active', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => AppUser.fromMap(
                doc.id,
                doc.data(),
              ),
            )
            .toList(),
      );
}


  /// Single user stream
  Stream<AppUser?> getUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;

      return AppUser.fromMap(doc.id, doc.data()!);
    });
  }

  /// Update user
  Future<void> updateUser(AppUser user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  /// Delete Firestore profile
  ///
  /// (Does NOT delete Firebase Authentication account.)
  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  /// Enable / Disable user
  Future<void> updateUserStatus(
    String uid,
    bool active,
  ) async {
    await _users.doc(uid).update({
      'active': active,
    });
  }
}
