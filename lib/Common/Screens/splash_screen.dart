import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Admin/Screens/admin.dashboard.screen.dart';
import 'package:the_heritedge/Common/Screens/home_page.dart';
import 'package:the_heritedge/User/login_sign_up/screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );
    controller.forward();

    Timer(Duration(seconds: 3), checkUserStatus);
  }

  Future<void> checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("Logged in user: $user");

    if (user != null) {
      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('roles_for_users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role') ?? 'user';
        print("User role: $role");

        if (role == 'admin'|| role== 'superadmin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        // If user doc not found, send to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.black45],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/splash_logo.jpg"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
