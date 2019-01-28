import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:ygoh_tournaments/EventTypeList.dart';
import 'package:ygoh_tournaments/PlayerInfo.dart';
import 'package:ygoh_tournaments/PlayerList.dart';
import 'package:ygoh_tournaments/account.dart';
import 'package:ygoh_tournaments/addScore.dart';
import 'package:ygoh_tournaments/addMembers.dart';
import 'package:ygoh_tournaments/bottomBar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.userId, this.user, this.admin}) : super(key: key);

  String userId;
  String user;
  bool admin;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _swiperController = new SwiperController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _bottomNavKey = GlobalKey<BottomNavBarState>();
  final _titleOptions = <String>[
    'Welcome',
    'Leaderboard',
    'Event Types',
  ];
  final _widgetOptions = <Widget>[
    PlayerInfo(),
    PlayerList(),
    EventTypeList(),
  ];
  final _alignmentOptions = [
    MainAxisAlignment.start,
    MainAxisAlignment.center,
    MainAxisAlignment.start,
  ];
  int _selectedIndex = 0;
  Widget _fab;

  @override
  initState() {
    PlayerInfo playerInfo = _widgetOptions[0];
    playerInfo.userId = widget.userId;
    playerInfo.user = widget.user;
    _titleOptions[0] = 'Welcome ${widget.user}';
    _fab = _fabForAdmins();
    super.initState();
  }

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
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Add Score",
          currentButton: FloatingActionButton(
            heroTag: "add_score",
            mini: true,
            child: Icon(FontAwesomeIcons.award),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddScoresScreen()),
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
    _titleOptions[0] = 'Welcome ${widget.user}';
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_titleOptions.elementAt(_selectedIndex)),
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
          setState(() {
            _selectedIndex = index;
          });
        },
        controller: _swiperController,
      ),
      floatingActionButton: _fab,
      bottomNavigationBar: bottomNavBar,
    );
  }
}