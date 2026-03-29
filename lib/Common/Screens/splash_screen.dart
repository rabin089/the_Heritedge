import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Common/Screens/home_page.dart';
import 'package:the_heritedge/User/login_sign_up/screens/login_page.dart';



class SplashScreen extends StatefulWidget {


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
    fadeAnimation= CurvedAnimation(
        parent: controller,
        curve:Curves.easeIn,
    );
    controller.forward();
    Timer(Duration(seconds: 3), (){
      User? user = FirebaseAuth.instance.currentUser;
      print("Logged in user: $user");
      if(user!=null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=> LoginScreen()));
      }
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Stack(
        fit:StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepPurpleAccent,Colors.black45],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
              ),
            ),
          Center(
            child:
            FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width *0.6,
                  height: MediaQuery.of(context).size.height *0.7,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                    image:AssetImage("assets/images/splash_logo.jpg"),
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
