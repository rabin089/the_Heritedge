import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/Screens/forget.password.dart';
import 'package:the_heritedge/Common/Screens/home_page.dart';
import 'package:the_heritedge/Common/Screens/signup_page.dart';
import 'package:the_heritedge/Services/auth_service.dart';
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

  void login()async{
    String email= emailControl.text.trim();
    String password= passwordControl.text.trim();
    var user= await authService.signIn(email, password);
    if(user!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Failed! Check credentails")));
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
