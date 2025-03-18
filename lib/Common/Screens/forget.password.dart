import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/sizedBox/sized.box.widget.dart';
import 'package:the_heritedge/Services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  void resetPassword() async {
    if (formKey.currentState!.validate()) {
      final error = await _authService.sendPasswordResetEmail(
        emailController.text.trim(),
      );
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reset link sent to your email")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(title: Text("Forgot Password")),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://www.tigerpalace.com/uploads/Tigerpalace/destination/local-attraction-detail-1.jpg',
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            ),
             SingleChildScrollView(
               child: Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 200.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
               
                          children: [
                            Text("Enter your email to receive a reset link.",
                              style: TextStyle(color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            sboxH20,
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.amber),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // <-- this
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Enter your email" : null,
                            ),
                            sboxH20,
                            ElevatedButton(
                              onPressed: resetPassword,
                              child: Text("Send Reset Link"),
                            ),
                          ],
                        ),
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
