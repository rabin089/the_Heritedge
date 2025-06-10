import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/connectors/v1.dart';
import 'package:the_heritedge/Common/widgets/search._bar.widget.dart';

import '../../User/login_sign_up/repository/auth_service.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService _authService = AuthService();
  final VoidCallback onMenuTap;
  final Future<dynamic> _userLocationFuture; // <- Pass this from your parent widget

  CustomAppBar({
    super.key,
    required this.onMenuTap,
    required Future<dynamic> userLocationFuture,
  }) : _userLocationFuture = userLocationFuture;

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
          icon: Icon(Icons.search,),
          color: Colors.white,
          onPressed: () async {
            final userPosition = await _userLocationFuture;
            showSearch(
              context: context,
              delegate: HeritageSearchDelegate(),
            );
          },
        ),
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
