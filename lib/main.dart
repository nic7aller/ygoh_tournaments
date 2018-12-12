import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:ygoh_tournaments/account.dart';
import 'package:ygoh_tournaments/addMembers.dart';
import 'package:ygoh_tournaments/login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ClubYGOHIO Tournaments',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        accentColor: Colors.black,
      ),
      home: new MySplashScreen(),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  @override
  _MySplashScreenState createState() => new _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  StatefulWidget _afterSplash = new LoginScreen();

  _isLoggedIn() async {
    final SharedPreferences prefs = await _prefs;
    String admin = prefs.getString('admin_user');
    if (admin != null) {
      setState(() {
        _afterSplash = new MyHomePage(user: admin);
      });
    } else {
      setState(() {
        _afterSplash = new LoginScreen(prefs: prefs);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn();
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: _afterSplash,
      title: new Text('We have been expecting you',
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 20.0
        ),),
      image: new Image.network('https://picsum.photos/400/400/?random'),
      backgroundColor: Colors.grey[900],
      styleTextUnderTheLoader: new TextStyle(color: Colors.white),
      photoSize: 100.0,
      loaderColor: Colors.red,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.user}) : super(key: key);

  String user;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _widgetOptions = [
    Text('Here is the main page, good user'),
    Text('Just another page, good user'),
    Text('Last one, good user'),
  ];

  _navigateAndUpdateUser(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen(user: widget.user)),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.user = prefs.getString('admin_user');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text('Welcome ' + widget.user),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            tooltip: 'Account Management',
            onPressed: () {_navigateAndUpdateUser(context); },
          ),
        ],
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _widgetOptions.elementAt(_selectedIndex),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMembersScreen()),
        ),
        tooltip: 'Add Member',
        child: new Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.child_care),
              title: Text('Child\'s Game')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.school),
              title: Text('School')
          ),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.red[900],
        onTap: _onItemTapped,
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
