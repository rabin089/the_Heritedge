import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/User/login_sign_up/provider/auth.provider.dart';
import 'package:the_heritedge/User/login_sign_up/screens/forget.password.dart';
import 'package:the_heritedge/Common/Screens/home_page.dart';
import 'package:the_heritedge/User/login_sign_up/screens/signup_page.dart';
import 'package:the_heritedge/User/login_sign_up/repository/auth_service.dart';
import 'package:the_heritedge/Common/sizedBox/sized.box.widget.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});



  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailControl= TextEditingController();
  final TextEditingController passwordControl= TextEditingController();
  final AuthService authService= AuthService();
  final keyForm = GlobalKey<FormState>();

  void login() async {
    String email = emailControl.text.trim();
    String password = passwordControl.text.trim();

    var user = await authService.signIn(email, password);
    if (user != null) {
      // 🔥 Fetch role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('roles_for_users')
          .doc(user.uid)
          .get();
      print("user uid: ${user.uid}");
      print("userDoc exists: ${userDoc.exists}");
      if (userDoc.exists) {
        final role = userDoc['role'];

        // ✅ Set role in AuthProvider
        Provider.of<AuthLoginProvider>(context, listen: false).setRole(role);

        // ⛳ Navigate to HomeScreen (can handle role-based redirection there)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User data not found.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed! Check credentials")),
      );
    }
  }


  @override
   Widget build(BuildContext context) {
     return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://www.discoveraltitude.com/uploads/media/world-heritage-sites-in-nepal/bouddhanath-stupa.jpg',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Card(
                    color: Colors.white30,
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: keyForm,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: emailControl,
                              decoration: InputDecoration(
                                labelText: "Email Address",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16
                                ),  
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  gapPadding: 10,
                                  
                                ),
                                iconColor: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: passwordControl,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            sboxH20,
                            ElevatedButton(
                                onPressed: login,
                                child: Text("login",
                                  style: TextStyle(color: Colors.black),
                                )),
                            sboxH20,
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(
                                    builder: (context) => ForgotPasswordScreen()));
                              },
                              child: Text("Forgot Password?", style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                            },
                            child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.black),)
                              

                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
