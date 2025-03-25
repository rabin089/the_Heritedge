import 'package:firebase_auth/firebase_auth.dart';
import '../utilities/sign_in_role_utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestoreService.saveUserData(user, 'user'); // Default role: user
      }

      return user;
    } catch (e) {
      print("Sign-up error: $e");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      Map<String, dynamic>? result = await _firestoreService.signInAndFetchRole(email, password);
      if (result != null && result['user'] is User) {
        return result['user'] as User?;
      }
      return null;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }


User? getCurrentUser(){
    return _auth.currentUser;
}

 Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // success
    } catch (e) {
      return e.toString(); // return error message
    }
  }
}
