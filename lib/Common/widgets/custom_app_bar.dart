import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/connectors/v1.dart';

import '../../User/login_sign_up/repository/auth_service.dart';
import '../providers/theme_provider.dart';
import 'heritage_location_search_delegate.dart';
import 'heritage_name_search_delegate.dart';

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
              final choice = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Choose Search Type'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text('Search by Location'),
                          onTap: () => Navigator.pop(context, 'location'),
                        ),
                        ListTile(
                          leading: Icon(Icons.text_fields),
                          title: Text('Search by Name'),
                          onTap: () => Navigator.pop(context, 'name'),
                        ),
                      ],
                    ),
                  );
                },
              );

              if (choice == 'location') {
                final userPosition = await _userLocationFuture;
                showSearch(
                  context: context,
                  delegate: HeritageLocationSearchDelegate(userLocation: userPosition),
                );
              } else if (choice == 'name') {
                showSearch(
                  context: context,
                  delegate: HeritageNameSearchDelegate(),
                );
              }
            }

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
