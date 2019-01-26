import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ygoh_tournaments/player.dart';

class EventTypeList extends StatefulWidget {
  EventTypeList({Key key}) : super(key: key);

  @override
  EventTypeListState createState() => new EventTypeListState();
}

class EventTypeListState extends State<EventTypeList> {
  final _numFormat = new NumberFormat("#,###", "en_US");

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('event-type')
          .orderBy('score_adder', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        int i = 1;
        return new Expanded(
          child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new ListView(
              children: snapshot.data.documents.map((document) {
                return new Material(
                  elevation: 2.0,
                  color: Theme.of(context).cardColor,
                  child: new InkWell(
                    splashColor: Colors.white70,
                    child: new ListTile(
                      leading: Text(_numFormat.format(i++)),
                      title: new Text(document['name']),
                      subtitle: new Text('Rank #1: ${_numFormat.format(document['score_adder'])}'),
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
