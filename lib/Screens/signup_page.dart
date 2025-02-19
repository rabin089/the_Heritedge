import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:the_heritedge/Screens/login_page.dart';
import 'package:the_heritedge/Services/auth_service.dart';
import 'package:the_heritedge/Screens/home_page.dart';


class SignupScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    var user = await _authService.signUp(email, password);
    if (user != null) {
      // Navigate to home screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Sign-up failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lifehimalayatrekking.com/wp-content/uploads/2023/11/Pashupatinath-Temple.webp',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.black12.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.0),
                
            
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Card(
                    color: Colors.black12.withOpacity(0.5),
                    elevation: 10.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 20,),
                            ElevatedButton(onPressed: _signUp, child: Text("Sign Up")),
                            TextButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                            },
                            child: Text("Already have an account? Login", style: TextStyle(color: Colors.white)))
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
