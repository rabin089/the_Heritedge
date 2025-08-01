import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/connectors/v1.dart';

import '../../User/login_sign_up/repository/auth_service.dart';
class AdminCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;

  AdminCustomAppBar({
    super.key,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: Color(0xFF795548),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            "Herit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Edge",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
