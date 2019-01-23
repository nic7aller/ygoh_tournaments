import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddScoresScreen extends StatefulWidget {
  @override
  _AddScoreScreenState createState() => new _AddScoreScreenState();
}

class _AddScoreScreenState extends State<AddScoresScreen> {

  final _nameController = new TextEditingController();
  final  _typeAheadController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  String _userId = '';
  DateTime _date;

  _onFormSubmit() async {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      String name = _nameController.text;
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Adding ' + name)));
      String snackMessage = await _addScore(name, _date);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackMessage)));
    }
  }

  _setUserIdIfEmpty(String name) async {
    if (this._userId.isEmpty) {
      await Firestore.instance.collection('users')
          .where('name', isEqualTo: name)
          .getDocuments()
          .then(
              (snapshot) {
            if (snapshot.documents.isNotEmpty) {
              this._userId = snapshot.documents[0].documentID;
            }
          }
      );
    }
  }

  FutureOr<List<DocumentSnapshot>> _getUsersThatIncludePattern(String pattern) async {
    QuerySnapshot snapshot = await Firestore.instance.collection('users').getDocuments();
    return snapshot.documents.where((doc) => doc.data['name'].contains(pattern)).toList();
  }

  _addScore(String name, DateTime date) async {
//    TODO: Add score to Firebase
//    String message = name + ' is now an event';
//    await Firestore.instance.collection('events')
//        .add({
//          'name': name,
//          'date': date,
//        })
//        .catchError((e) {
//          message = 'Event could not be added';
//        }
//    );
//    return message;
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              title:
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: this._typeAheadController,
                    decoration: const InputDecoration(
                      hintText: 'Ryan Arnold',
                      labelText: 'Member Name',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                ),
                getImmediateSuggestions: true,
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
                  this._typeAheadController.text = suggestion.data['name'];
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
            leading: const Icon(Icons.event_seat),
            title:
              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Weekly Tournament #0',
                  labelText: 'Event Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name';
                  }
                },
                controller: _nameController,
              )
            ),
            new ListTile(
                leading: const Icon(Icons.event),
                title:
                DateTimePickerFormField(
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  initialDate: DateTime.now(),
                  dateOnly: true,
                  format: _dateFormat,
                  onChanged: (dt) => setState(() => _date = dt),
                )
            ),
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