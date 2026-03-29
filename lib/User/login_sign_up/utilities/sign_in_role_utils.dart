import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔍 Fetch User Role
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('roles_for_users').doc(uid).get();
      return doc.data()?['role']; // Returns 'admin' or 'user'
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }

  // 🔑 Sign In & Fetch Role
  Future<Map<String, dynamic>?> signInAndFetchRole(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        String? role = await getUserRole(user.uid);
        return {
          'user': user,
          'role': role,
        };
      }
    } catch (e) {
      print("Sign-in error: $e");
    }
    return null;
  }

  // 📝 Save User Data on Sign Up
  Future<void> saveUserData(User user, String role) async {
    try {
      await _firestore.collection('roles_for_users').doc(user.uid).set({
        'email': user.email,
        'role': role,
      });
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
}
