import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class PlayerList extends StatefulWidget {
  PlayerList({Key key}) : super(key: key);

  @override
  PlayerListState createState() => new PlayerListState();
}

class PlayerListState extends State<PlayerList> {
  final f = new NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users')
          .orderBy('score', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new Expanded(
          child: new ListView(
            children: snapshot.data.documents.map((document) {
              return new ListTile(
                title: new Text(document['name']),
                trailing: new Text(f.format(document['score'])),
              );
            }).toList(),
          )
        );
      },
    );
  }
}
