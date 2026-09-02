import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_paths.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return _fetchAppUser(firebaseUser.uid);
  }

  Future<AppUser?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final uid = cred.user?.uid;
    if (uid == null) return null;
    return _fetchAppUser(uid);
  }

  /// Sign-up path used by Super Admin / Head Coach to provision new
  /// coaches/trainees. Regular self-serve sign-up is intentionally not
  /// exposed since this is an invite-only coaching org platform.
  Future<AppUser> createUser({
    required String organisationId,
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = cred.user!.uid;
    final appUser = AppUser(
      id: uid,
      email: email,
      displayName: displayName,
      role: role,
      organisationId: organisationId,
      createdAt: DateTime.now(),
    );
    await _db
        .doc(FirestorePaths.user(organisationId, uid))
        .set(appUser.toMap());
    return appUser;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// NOTE: in the org-scoped data model, we need to know which org a user
  /// belongs to before we can look them up. In production this is solved
  /// with a small top-level `userIndex/{uid} -> organisationId` lookup
  /// collection populated on user creation. Stubbed here for the scaffold.
  ///

  // Future<AppUser?> _fetchAppUser(String uid) async {
  //   final indexDoc = await _db.collection('userIndex').doc(uid).get();
  //   final orgId = indexDoc.data()?['organisationId'];
  //   if (orgId == null) return null;
  //   final doc = await _db.doc(FirestorePaths.user(orgId, uid)).get();
  //   if (!doc.exists) return null;
  //   return AppUser.fromMap(doc.id, doc.data()!);
  // }

  Future<AppUser?> _fetchAppUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      print("User profile not found");
      return null;
    }

    return AppUser.fromMap(doc.id, doc.data()!);
  }
}
