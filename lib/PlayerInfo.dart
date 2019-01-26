import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class PlayerInfo extends StatefulWidget {
  PlayerInfo({Key key, this.userId, this.user}) : super(key: key);

  @required String userId;
  @required String user;

  @override
  _PlayerInfoState createState() => new _PlayerInfoState(userId);
}

class _PlayerInfoState extends State<PlayerInfo> {
  final _numFormat = new NumberFormat("#,###", "en_US");
  final _dateFormat = new DateFormat('MMM d, yyyy');
  Map<String, Map<String, dynamic>> _eventTypes;
  List<bool> _isExpanded;
  String _fScore = '';

  _PlayerInfoState(String userId) {
    initState();
    Firestore.instance.collection('users').document(userId).get().then((doc) {
      if (mounted)
        setState(() {
          _fScore = 'Score: ' + _numFormat.format(doc['score']);
        });
    });
    Firestore.instance.collection('event-type').getDocuments().then((snapshot) {
      List<DocumentSnapshot> docs = snapshot.documents;
      if (mounted)
        setState(() {
          _eventTypes = Map.fromEntries(
              docs.map((doc) => new MapEntry(doc.documentID, doc.data))
          );
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    String user = widget.user;
    return new Column(children: <Widget>[
      new Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: new Row(
          children: <Widget>[
            Image.network(
              'https://robohash.org/$userId.png',
              scale: 3.0,
            ),
            new Column(
              children: <Widget>[
                new Text(user, textScaleFactor: 1.5,),
                new Text(_fScore, textScaleFactor: 1.2,),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
      ),
      new StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(userId)
              .collection('scores')
              .orderBy('date', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');
            if (_isExpanded == null || _isExpanded.isEmpty) {
              _isExpanded = new List<bool>.generate(
                  snapshot.data.documents.length, (i) => false);
            }
            int i = 0;
            return new Container(
                margin: const EdgeInsets.all(16.0),
                child: new ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isExpanded[index] = !isExpanded;
                    });
                  },
                  children: snapshot.data.documents.map((doc) {
                    return new ExpansionPanel(
                      isExpanded: _isExpanded[i],
                      headerBuilder: (context, isExpanded) => new ListTile(
                        leading:
                            new Text(_dateFormat.format(doc['date'])),
                        title: new Text(
                            _eventTypes == null
                                ? 'Loading...'
                                : _eventTypes[doc['type_id']]['name']
                        ),
                      ),
                      body: new Container(
                        margin: const EdgeInsets.only(
                            bottom: 32.0, left: 16.0, right: 16.0
                        ),
                        child: new Row(
                          children: <Widget>[
                            new Column(
                              children: <Widget>[
                                new Text('Details: ' + doc['details']),
                                new Text('Rank: ' +
                                    _numFormat.format(doc['position'])),
                                new Text('Score: ' +
                                    (_eventTypes == null
                                        ? 'Loading...'
                                        : _numFormat.format(
                                        _eventTypes[doc['type_id']]['score_adder'] - doc['position'] + 1))
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ]
                        )
                      ),
                    );
                  }).toList(),
                ));
          }),
    ]);
  }
}
