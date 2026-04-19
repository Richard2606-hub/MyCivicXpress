import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/citizen_profile.dart';
import '../models/govtech_models.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Auth & Profile ---
  
  Future<UserCredential?> signUp(String email, String password, CitizenProfile profile) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        // Save profile to Firestore
        await _db.collection('users').doc(credential.user!.uid).set(profile.toMap());
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<CitizenProfile?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return CitizenProfile.fromMap(doc.data()!);
    }
    return null;
  }

  // --- Appointments ---

  Future<void> bookAppointment(CivicAppointment appointment) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('appointments').add({
      ...appointment.toMap(),
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<CivicAppointment?> getLatestAppointment() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _db
        .collection('appointments')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return CivicAppointment.fromMap(snapshot.docs.first.data());
        });
  }

  // --- Complaints ---

  Future<void> submitComplaint(CivicComplaint complaint) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('complaints').add({
      ...complaint.toMap(),
      'userId': uid,
      'status': ComplaintStatus.pending.index,
    });
  }

  Stream<List<CivicComplaint>> getMyComplaints() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('complaints')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => CivicComplaint.fromMap(doc.data())).toList();
        });
  }

  // --- Impact Score ---

  Future<void> updateImpactScore(int points) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'impactScore': FieldValue.increment(points),
    });
  }
}
