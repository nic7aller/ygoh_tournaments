import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ygoh_tournaments/PlayerInfo.dart';
import 'package:ygoh_tournaments/main.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key key, this.userId, this.user}) : super(key: key);

  final String userId;
  final String user;

  @override
  _PlayerScreenState createState() => new _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Player Info"),
      ),
      body: new PlayerInfo(userId: widget.userId, user: widget.user), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}