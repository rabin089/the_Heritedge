import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/providers/theme_provider.dart';
import 'package:the_heritedge/services/auth_service.dart';





class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService _authService = AuthService();
  final VoidCallback onMenuTap;
  CustomAppBar({Key? Key,required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // For Dark Mode Toggle

    return AppBar(
      backgroundColor: Color(0xFFA1887F),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text("Herit",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          ),
          Text("Edge",
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
