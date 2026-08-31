import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Total Programmes
final programmeCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('programmes')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Total Users
final totalUsersProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Coaches
final coachesProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'coach')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Trainees
final traineesProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'trainee')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});