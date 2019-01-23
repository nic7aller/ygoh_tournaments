import 'package:flutter/material.dart';
import 'package:ygoh_tournaments/splash.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ClubYGOHIO Tournaments',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        accentColor: Colors.black,
      ),
      home: new ASplashScreen(),
    );
  }
}
