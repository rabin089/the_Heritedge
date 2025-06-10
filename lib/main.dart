import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/Admin/provider/add.heritage.provider.dart';
import 'package:the_heritedge/User/login_sign_up/provider/auth.provider.dart';
import 'package:the_heritedge/User/ui/provider/contribution.provider.dart';
import 'package:the_heritedge/myApp.dart';

import 'Common/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AuthLoginProvider().loadRole();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthLoginProvider()),
        ChangeNotifierProvider(create: (context) => ContributionProvider()),
        ChangeNotifierProvider(create: (context) => AdminHeritageProvider()),
      ],
      child: MyApp(),
    ),
  );
}
