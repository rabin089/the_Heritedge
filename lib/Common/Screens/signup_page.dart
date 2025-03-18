import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_heritedge/Common/Screens/login_page.dart';
import 'package:the_heritedge/Services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String username = _usernameController.text.trim();
      String mobile = _mobileController.text.trim();
      String password = _passwordController.text.trim();

      var user = await _authService.signUp(email, password);
      if (user != null) {
        // Store additional user info in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'mobile': mobile,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully!")),
        );

        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up failed!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lifehimalayatrekking.com/wp-content/uploads/2023/11/Pashupatinath-Temple.webp',
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(color: Colors.white30.withOpacity(0.2)),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Card(
                        color: Colors.white30.withOpacity(0.2),
                        elevation: 10.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildTextField(_emailController, "Email Address", TextInputType.emailAddress, (value) {
                                  if (value == null || value.isEmpty) return "Please enter your email";
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
                                  return null;
                                }),
                                buildTextField(_usernameController, "Username", TextInputType.text, (value) {
                                  if (value == null || value.isEmpty) return "Please enter a username";
                                  return null;
                                }),
                                buildTextField(_mobileController, "Mobile Number", TextInputType.phone, (value) {
                                  if (value == null || value.isEmpty) return "Please enter a mobile number";
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Enter a valid 10-digit number";
                                  return null;
                                }),
                                buildTextField(_passwordController, "Password", TextInputType.visiblePassword, (value) {
                                  if (value == null || value.isEmpty) return "Please enter a password";
                                  if (value.length < 6) return "Password must be at least 6 characters";
                                  return null;
                                }, isPassword: true),
                                buildTextField(_confirmPasswordController, "Confirm Password", TextInputType.visiblePassword, (value) {
                                  if (value != _passwordController.text) return "Passwords do not match";
                                  return null;
                                }, isPassword: true),
                                SizedBox(height: 20),
                                ElevatedButton(onPressed: _signUp, child: Text("Sign Up")),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                  },
                                  child: Text("Already have an account? Login", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget buildTextField(TextEditingController controller, String label, TextInputType keyboardType, FormFieldValidator<String> validator, {bool isPassword = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      ),
      style: TextStyle(color: Colors.black),
      validator: validator,
    ),
  );
}