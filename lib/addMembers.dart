import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUsersScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => new _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUsersScreen> {

  final _controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _termsChecked = false;

  _onFormSubmit() async {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      String name = _controller.text;
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Adding ' + name)));
      String snackMessage = await _addUser(name, _termsChecked );
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(snackMessage)));
    }
  }

  _addUser(String name, bool isAdmin) async {
    String message = name + ' is now a user';
    await Firestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .getDocuments()
        .then((snapshot) {
          if (snapshot.documents.length == 0) {
            Firestore.instance.collection('users')
                .add({
                  'name': name,
                  'password': 'password',
                  'admin': isAdmin,
                  'score': 0
                })
                .catchError((e) {
                  message = 'User could not be added';
                }
            );
          } else {
            message = '$name is already a user';
          }
        }).catchError((e) {
          message = 'User could not be added';
        });
    return message;
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
        title: new Text("Add Users"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            new ListTile(
            leading: const Icon(Icons.person),
            title:
              TextFormField(
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
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name';
                  }
                },
                controller: _controller,
              )
            ),
            new CheckboxListTile(
              title: new Text('Check here for this user to be an admin'),
              value: _termsChecked,
              onChanged: (bool value) =>
                  setState(() => _termsChecked = value),
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