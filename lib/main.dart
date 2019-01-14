import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:ygoh_tournaments/account.dart';
import 'package:ygoh_tournaments/addMembers.dart';
import 'package:ygoh_tournaments/bottomBar.dart';
import 'package:ygoh_tournaments/login.dart';

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
    String user = prefs.getString('current_user');
    bool admin = prefs.getBool('admin_status');
    if (user != null) {
      setState(() {
        _afterSplash = new MyHomePage(user: user, admin: admin);
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
      title: new Text(
        'We have been expecting you',
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 20.0),
      ),
      image: new Image.network('https://picsum.photos/400/400/?random'),
      backgroundColor: Colors.grey[900],
      styleTextUnderTheLoader: new TextStyle(color: Colors.white),
      photoSize: 100.0,
      loaderColor: Colors.red,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.user, this.admin}) : super(key: key);

  String user;
  bool admin;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _swiperController = new SwiperController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _bottomNavKey = GlobalKey<BottomNavBarState>();
  final _widgetOptions = [
    Text('Here is the main page, good user'),
    Text('Just another page, good user'),
    Text('THE FINAL PAGE'),
  ];
  final _alignmentOptions = [
    MainAxisAlignment.center,
    MainAxisAlignment.center,
    MainAxisAlignment.start,
  ];

  _navigateAndUpdateUser(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen(user: widget.user)),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.user = prefs.getString('current_user');
    });
  }

  Widget _fabForAdmins() {
    if (widget.admin) {
      var childButtons = List<UnicornButton>();
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Add User",
          currentButton: FloatingActionButton(
            heroTag: "add_user",
            mini: true,
            child: Icon(FontAwesomeIcons.userAstronaut),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddUsersScreen()),
                ),
          )));
      return new UnicornDialer(
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(FontAwesomeIcons.plus),
        finalButtonIcon: Icon(FontAwesomeIcons.times),
        childButtons: childButtons,
        animationDuration: 100,
        hasBackground: false,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final bottomNavBar = BottomNavBar(
        key: _bottomNavKey,
        controller: _swiperController,
        index: _selectedIndex,
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Welcome ' + widget.user),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            tooltip: 'Account Management',
            onPressed: () {
              _navigateAndUpdateUser(context);
            },
          ),
        ],
      ),
      body: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return new Column(
              mainAxisAlignment: _alignmentOptions.elementAt(index),
              children: <Widget>[
                _widgetOptions.elementAt(index),
              ]);
        },
        itemCount: 3,
        index: _selectedIndex,
        loop: true,
        onIndexChanged: (index) {
          _selectedIndex = index;
          if (_bottomNavKey.currentState.widget.index != index)
            _bottomNavKey.currentState.updateIndex(_selectedIndex);
        },
        controller: _swiperController,
      ),
      floatingActionButton: _fabForAdmins(),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
