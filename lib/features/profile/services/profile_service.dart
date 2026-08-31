import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../data/models/app_user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// =====================================================
  /// Current User Stream
  /// =====================================================

  Stream<AppUser?> getCurrentUserStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      return AppUser.fromMap(
        doc.id,
        doc.data()!,
      );
    });
  }

  /// =====================================================
  /// Update Profile
  /// =====================================================

  Future<void> updateProfile(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(user.toMap());
  }

  /// =====================================================
  /// Upload Profile Photo
  /// =====================================================

  Future<String> uploadProfilePhoto(
    String uid,
    File image,
  ) async {
    final ref = _storage.ref().child(
          'profile_photos/$uid.jpg',
        );

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  /// =====================================================
  /// Update Photo URL
  /// =====================================================

  Future<void> updatePhotoUrl(
    String uid,
    String photoUrl,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  /// =====================================================
  /// Change Password
  /// =====================================================

  Future<void> changePassword(
    String newPassword,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No logged in user.");
    }

    await user.updatePassword(newPassword);
  }

  /// =====================================================
  /// Logout
  /// =====================================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}