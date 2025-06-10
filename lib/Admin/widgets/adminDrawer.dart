import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_heritedge/Admin/Screens/add.heritage.screen.dart';
import '../../Common/Screens/change.password.page.dart';
import '../../User/login_sign_up/screens/login_page.dart';
import '../Screens/admin.dashboard.screen.dart';

class AdminDrawer extends StatelessWidget {
  AdminDrawer({super.key});
  final User? user = FirebaseAuth.instance.currentUser;
  bool isAdmin = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.brown),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        user?.displayName??'Admin',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    Divider(),
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
            ),
            Expanded(
              child: ListView(
                children: [
                  DrawerNavItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.comment,
                    label: 'Add Heritage',
                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminAddHeritageScreen()));
                    },
                  ),
                  DrawerNavItem(
                    icon: Icons.add,
                    label: 'Settings',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePasswordScreen()));
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            DrawerNavItem(
              icon: Icons.exit_to_app,
              label: 'Logout',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
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

class DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DrawerNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(label),
      onTap: onTap,
    );
  }
}
