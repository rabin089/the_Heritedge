import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/Admin/Screens/admin.dashboard.screen.dart';
import 'package:the_heritedge/Common/Screens/change.password.page.dart';
import 'package:the_heritedge/User/login_sign_up/provider/auth.provider.dart';
import 'package:the_heritedge/User/login_sign_up/screens/login_page.dart';
import 'package:the_heritedge/Common/widgets/custom_text.widget.dart';
import 'package:the_heritedge/User/ui/screens/contribution.screen.dart';
import 'package:the_heritedge/User/ui/screens/user_profile.page.dart';

import '../../trial/trialPage.dart';
import '../Screens/saved.location.page.dart';

class AppDrawer extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            // Header
            Container(
              height: 88,
              width: double.infinity,
              color: Colors.brown,
              padding: EdgeInsets.only(top: 40, right: 16),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "HeritEdge",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
      
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Profile"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfileScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text("My Edge Collection"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookmarkListScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text("Contributions"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContributionScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePasswordScreen()));
                    },
                  ),
                  Consumer<AuthLoginProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.role == 'admin') {
                        return ListTile(
                          leading: Icon(Icons.dashboard),
                          title: Text("Admin Dashboard"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminDashboardScreen(),
                              ),
                            );
                          },
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
      
                  // ListTile(
                  //   leading: Icon(Icons.logout, color: Colors.red),
                  //   title: Text("Demo Page", style: TextStyle(color: Colors.red)),
                  //   onTap: ()  {
                  //
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => DemoHomeScreen()),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
      
            // Divider & Logout button
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                print("Logged out user: $user");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

