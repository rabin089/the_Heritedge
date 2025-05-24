import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(child: Text('Admin Navigation')),
          DrawerNavItem(icon: Icons.analytics, label: 'Analytics'),
          DrawerNavItem(icon: Icons.people, label: 'Users'),
          DrawerNavItem(icon: Icons.landscape, label: 'Heritage Sites'),
          DrawerNavItem(icon: Icons.event, label: 'Festivals'),
          DrawerNavItem(icon: Icons.comment, label: 'Moderation'),
        ],
      ),
    );
  }
}

class DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const DrawerNavItem({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // Implement navigation logic here
      },
    );
  }
}
