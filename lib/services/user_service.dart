import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_paths.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AppUser>> watchUsers(String orgId, {UserRole? role}) {
    Query<Map<String, dynamic>> q = _db.collection(FirestorePaths.users(orgId));
    if (role != null) {
      q = q.where('role', isEqualTo: role.name);
    }
    return q.snapshots().map((snap) => snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  Future<void> setActive(String orgId, String userId, bool isActive) {
    return _db.doc(FirestorePaths.user(orgId, userId)).update({'isActive': isActive});
  }

  Future<void> updateRole(String orgId, String userId, UserRole role) {
    return _db.doc(FirestorePaths.user(orgId, userId)).update({'role': role.name});
  }
}
