import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Screens/login_page.dart';
import 'package:the_heritedge/widgets/custom_text.widget.dart';

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
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.redAccent,

            ),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          ListTile(
            title: CustomTextWidget(text: "Home", color: Colors.red),
            onTap: (){
    }),

      ListTile(
        leading: Icon(Icons.person),
         title: Text("Profile"),
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
