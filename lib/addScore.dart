import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ygoh_tournaments/FireDropdownButton.dart';

class AddScoresScreen extends StatefulWidget {
  @override
  _AddScoreScreenState createState() => new _AddScoreScreenState();
}

class _AddScoreScreenState extends State<AddScoresScreen> {
  final _detailsController = new TextEditingController();
  final _rankController = new TextEditingController();
  final _nameSelectController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  List<List<dynamic>> _previousScores;
  FocusNode _focusNode;
  DateTime _date;
  String _userId;
  String _userName;
  String _eventTypeId;

  @override
  initState() {
    _previousScores = [];
    _userId = '';
    _userName = '';
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _formKey.currentState.save();
      }
    });
    super.initState();
  }

  _onFormSubmit() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      String name = _detailsController.text;
      int rank = int.parse(_rankController.text);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Adding ' + name)));
      String snackMessage =
          await _addScore(name, _date, rank, _eventTypeId);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(snackMessage)));
    }
  }

  void _setUserIdIfEmpty(name) async {
    if (this._userId.isEmpty || this._userName != name) {
      Firestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .getDocuments()
          .then((snapshot) {
        if (snapshot.documents.isNotEmpty) {
          this._userId = snapshot.documents[0].documentID;
          this._userName = name;
        }
      }).catchError(() => this._userId = '');
    }
  }

  FutureOr<List<DocumentSnapshot>> _getUsersThatIncludePattern(
      String pattern) async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('users').getDocuments();
    return snapshot.documents
        .where((doc) => doc.data['name'].contains(pattern))
        .toList();
  }

  _addScore(String details, DateTime date, int rank, String type) async {
    String message = 'Score added for ' + _userName;
    List<dynamic> newScoreList = [details, date, type, rank];
    if (isListInList(_previousScores, newScoreList)) {
      message = 'You have previously added this same score for $_userName';
      return message;
    }
    int nScore, maxRank;
    await Firestore.instance
        .collection('event-type')
        .document(type).get()
        .then((doc) {
          nScore = doc.data['score_adder'];
          maxRank = doc['max_rank'];
        });
    if (maxRank < rank)
      return 'Rank must be at most $maxRank for this event type';
    nScore = nScore - rank + 1;
    DocumentReference userRef = Firestore.instance
        .collection('users').document(_userId);
    await userRef.get()
        .then((doc) {
          int ogScore = doc.data['score'];
          userRef.updateData({'score': ogScore + nScore,});
        })
        .catchError((e) {
          message = 'Score could not be added to user';
          debugPrint('Score not updated in Firestore');
        });
    await userRef
        .collection('scores')
        .add({
          'details': details,
          'date': date,
          'type_id': type,
          'position': rank,
        })
        .then((ref) => _previousScores.add(newScoreList))
        .catchError((e) {
          message = 'Event could not be added to user';
        });
    return message;
  }

  static bool isListInList(List<List> listOfLists, List list) {
    for (List inList in listOfLists) {
      bool allIn = true;
      for (var item in list) {
        allIn = allIn && inList.contains(item);
      }
      if (allIn) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Add Scores"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.person),
              title: TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: this._nameSelectController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Ryan Arnold',
                    labelText: 'Member Name',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  focusNode: _focusNode,
                ),
                getImmediateSuggestions: false,
                suggestionsCallback: _getUsersThatIncludePattern,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.data['name']),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  this._nameSelectController.text = suggestion.data['name'];
                  this._userName = suggestion.data['name'];
                  this._userId = suggestion.documentID;
                },
                validator: (value) {
                  if (value.isEmpty || this._userId.isEmpty) {
                    return 'Please select a valid member name';
                  }
                },
                onSaved: _setUserIdIfEmpty,
              ),
            ),
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
                collection: 'event-type',
                prettyField: 'name',
                orderField: 'score_adder',
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
                child: Text('Add'),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
