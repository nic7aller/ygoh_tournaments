import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ygoh_tournaments/FireDropdownButton.dart';

class EditScoreScreen extends StatefulWidget {
  EditScoreScreen(
      {
        Key key,
        this.userId,
        this.user,
        this.scoreId,
        this.details,
        this.date,
        this.rank,
        this.type,
        this.score
      }
  ) : super(key: key);

  final String userId;
  final String user;
  final String scoreId;
  final String details;
  final DateTime date;
  final int rank;
  final String type;
  final int score;

  @override
  _EditScoreScreenState createState() => new _EditScoreScreenState();
}

class _EditScoreScreenState extends State<EditScoreScreen> {
  final _detailsController = new TextEditingController();
  final _rankController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _dropdownKey = GlobalKey<FormFieldState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final _numFormat = new NumberFormat("#,###", "en_US");
  String _userId;
  String _userName;
  String _scoreId;
  String _oDetails;
  DateTime _oDate;
  int _oRank;
  String _oType;
  int _oScore;
  DateTime _date;
  String _eventTypeId;

  @override
  initState() {
    _userId = widget.userId;
    _userName = widget.user;
    _scoreId = widget.scoreId;
    _oDetails = widget.details;
    _oDate = widget.date;
    _oRank = widget.rank;
    _oType = widget.type;
    _oScore = widget.score;
    _date = _oDate;
    _eventTypeId = _oType;
    _detailsController.text = _oDetails;
    _rankController.text = _numFormat.format(_oRank);
    super.initState();
  }

  _onFormSubmit() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      String details = _detailsController.text;
      int rank = int.parse(_rankController.text);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Updating score')));
      String snackMessage =
          await _updateScore(details, _date, rank, _eventTypeId);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(snackMessage)));
    }
  }

  _updateScore(String details, DateTime date, int rank, String type) async {
    String message = 'Score edited for ' + _userName;
    int nScore, maxRank;
    await Firestore.instance
        .collection('event-type')
        .document(type).get()
        .then((doc) {
          nScore = doc['score_adder'];
          maxRank = doc['max_rank'];
        });
    if (maxRank < rank)
      return 'Rank must be at most $maxRank for this event type';
    DocumentReference userRef = Firestore.instance
        .collection('users').document(_userId);
    nScore = nScore - rank + 1;
    if (nScore != _oScore) {
      await userRef.get()
          .then((doc) {
            int ogScore = doc['score'];
            userRef.updateData({'score': ogScore + nScore - _oScore,});
          })
          .catchError((e) {
            message = 'Score could not be updated';
            debugPrint('Score not updated in Firestore');
          });
    }
    await userRef
        .collection('scores')
        .document(_scoreId)
        .updateData({
          'details': details,
          'date': date,
          'type_id': type,
          'position': rank,
        })
        .catchError((e) {
          message = 'Event could not be updated';
        });
    return message;
  }

  _onDelete() async {
    _formKey.currentState.save();
    bool didDelete = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Score?'),
          content: SingleChildScrollView(
            child: Text('Choosing delete will permanently delete the score you are editing')
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel', style: new TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Delete', style: new TextStyle(color: Colors.white)),
              onPressed: () async {
                var snackMessage = await _deleteScore();
                _scaffoldKey.currentState
                    .showSnackBar(SnackBar(content: Text(snackMessage)));
                Navigator.of(context).pop(snackMessage?.contains(_userName));
              },
            ),
          ],
        );
      },
    );
    if (didDelete) {
      Navigator.of(context).pop();
    }
  }

  _deleteScore() async {
    String message = 'Score deleted for ' + _userName;
    DocumentReference userRef = Firestore.instance
        .collection('users').document(_userId);
    DocumentReference scoreRef = userRef
        .collection('scores').document(_scoreId);
    await Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(userRef);
      if (postSnapshot.exists) {
        await tx.update(userRef, <String, dynamic>{
          'score': postSnapshot.data['score'] - _oScore
        });
      }
      await tx.delete(scoreRef);
    }).catchError((e) => message = 'Score not deleted');
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Edit Score"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.event),
              title: DateTimePickerFormField(
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                dateOnly: true,
                initialValue: _oDate,
                format: _dateFormat,
                onChanged: (dt) => setState(() => _date = dt),
                validator: (value) {
                  if (value == null) {
                    return 'Please select the start date of the event';
                  }
                },
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.event_seat),
              title: new FireDropdownButton(
                key: _dropdownKey,
                collection: 'event-type',
                prettyField: 'name',
                orderField: 'score_adder',
                initialValue: _oType,
                validator: (value) {
                  if (value == null) {
                    return 'Please select an event type';
                  }
                },
                onSaved: (value) => _eventTypeId = value,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            new ListTile(
                leading: const Icon(Icons.event_note),
                title: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Weekly Tournament #0',
                    labelText: 'Event Details',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some details about the event';
                    }
                  },
                  controller: _detailsController,
                  maxLines: null,
                )),
            new ListTile(
                leading: const Icon(FontAwesomeIcons.medal),
                title: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: '1',
                    labelText: 'Event Rank',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty || int.tryParse(value) == null) {
                      return 'Please select a valid integer rank';
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: _rankController,
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: _onFormSubmit,
                child: Text('Update'),
              ),
            ),
            Container(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: _onDelete,
                child: Text('Delete'),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
