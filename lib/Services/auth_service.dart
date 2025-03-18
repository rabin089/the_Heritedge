import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth auth= FirebaseAuth.instance;
  Future<User?> signUp(String email, String password) async{
    try{
      UserCredential userCredential= await auth.createUserWithEmailAndPassword(
          email: email,
          password: password);
      return userCredential.user;
    }
    catch(e){
      print("sign up error:$e");
    }
    return null;
  }
  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }


  Future<void> signout()async{
    await auth.signOut();
}

User? getCurrentUser(){
    return auth.currentUser;
}
 Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null; // success
    } catch (e) {
      return e.toString(); // return error message
    }
  }
}