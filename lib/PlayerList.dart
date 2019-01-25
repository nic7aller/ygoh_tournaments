import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ygoh_tournaments/player.dart';

class PlayerList extends StatefulWidget {
  PlayerList({Key key}) : super(key: key);

  @override
  PlayerListState createState() => new PlayerListState();
}

class PlayerListState extends State<PlayerList> {
  final _numFormat = new NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users')
          .orderBy('score', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        int i = 1;
        return new Expanded(
          child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new ListView(
              children: snapshot.data.documents.map((document) {
                return new Material(
                  color: Theme.of(context).cardColor,
                  child: new InkWell(
                    splashColor: Colors.white70,
                    child: new ListTile(
                      leading: Text(_numFormat.format(i++)),
                      title: new Text(document['name']),
                      trailing: new Text(_numFormat.format(document['score'])),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                          new PlayerScreen(
                              userId: document.documentID,
                              user: document['name']
                          )
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          ),
        );
      },
    );
  }
}
