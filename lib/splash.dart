import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:ygoh_tournaments/home.dart';
import 'package:ygoh_tournaments/login.dart';

class ASplashScreen extends StatefulWidget {
  @override
  _ASplashScreenState createState() => new _ASplashScreenState();
}

class _ASplashScreenState extends State<ASplashScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  StatefulWidget _afterSplash = new LoginScreen();

  _isLoggedIn() async {
    final SharedPreferences prefs = await _prefs;
    String user = prefs.getString('current_user');
    bool admin = prefs.getBool('admin_status');
    if (user != null) {
      QuerySnapshot snapshot = await Firestore.instance
          .collection('users').where('name', isEqualTo: user).getDocuments();
      if (snapshot.documents.isNotEmpty) {
        String userId = snapshot.documents
            .where((doc) => doc['name'] == user).elementAt(0).documentID;
        if (this.mounted) {
          setState(() {
            _afterSplash =
            new HomePage(userId: userId, user: user, admin: admin);
          });
          return;
        }
      }
    }
    if (this.mounted)
      setState(() {
        _afterSplash = new LoginScreen(prefs: prefs);
      });
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn();
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: _afterSplash,
      title: new Text(
        'We have been expecting you',
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 20.0,
        ),
      ),
      image: new Image.asset('assets/club_logo.jpg'),
      backgroundColor: Colors.grey[900],
      styleTextUnderTheLoader: new TextStyle(color: Colors.white),
      photoSize: 100.0,
      loaderColor: Colors.red,
    );
  }
}