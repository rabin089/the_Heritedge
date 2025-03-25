import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/Admin/Screens/admin.dashboard.screen.dart';
import 'package:the_heritedge/User/login_sign_up/provider/auth.provider.dart';
import 'package:the_heritedge/User/login_sign_up/screens/login_page.dart';
import 'package:the_heritedge/Common/widgets/custom_text.widget.dart';

class AppDrawer extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

   AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    print(build);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 100, // Custom height here
            width: double.infinity,
            color: Colors.brown,
            padding: EdgeInsets.only(top: 40, right: 16), // Adjust top padding as needed
            child: Row(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("HeritEdge",
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
          ListTile(
            leading: Icon(Icons.home),
            title: CustomTextWidget(text: "Home"),
            onTap: (){
              }),

      ListTile(
        leading: Icon(Icons.person),
         title: Text("Profile"),
        onTap: (){},
       ),
    ListTile(
    leading: Icon(Icons.bookmark),
    title: Text("Bookmarks"),
    onTap: (){},
    ),
    ListTile(
    leading: Icon(Icons.edit),
    title: Text("Contributions"),
    onTap: (){},
    ),
    ListTile(
    leading: Icon(Icons.explore),
    title: Text("Explore Nearby"),
    onTap: (){},
    ),
    ListTile(
    leading: Icon(Icons.settings),
    title: Text("Settings"),
    onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.dashboard),
    title: Text("Admint Dashboard"),
    onTap: (){
      final role = Provider.of<AuthLoginProvider>(context, listen: false).role;
      if (role == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You are not authorized to access this page.")),
        );
        Navigator.pop(context);
      }
    },
    ),
    Divider(),
    ListTile(
    leading: Icon(Icons.logout, color: Colors.red),
    title: Text("Logout", style: TextStyle(color: Colors.red)),
    onTap: () async{
      await FirebaseAuth.instance.signOut();
      print("Logged out user: $user");
    Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (context) => LoginScreen()));
    },
    ),
        ],
      ),
    );
  }
}
