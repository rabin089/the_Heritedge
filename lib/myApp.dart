import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_heritedge/Common/Screens/splash_screen.dart';
import 'package:the_heritedge/Common/Theme/dark_theme.dart';
import 'Common/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HeritEdge",
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode, // Uses provider's theme
      home:SplashScreen(),
    );
  }
}