import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMembersScreen extends StatefulWidget {
  @override
  _AddMemberScreenState createState() => new _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMembersScreen> {

  final _controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onFormSubmit() {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      String name = _controller.text;
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Adding ' + name)));
      _addMember(name);
    }
  }

  void _addMember(String memberName) {
    Firestore.instance.collection('members').document(memberName)
        .setData({ 'score': 0 });
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
        title: new Text("Add Members"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            new ListTile(
            leading: const Icon(Icons.person),
            title:
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Ryan Arnold',
                  labelText: 'Member Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name';
                  }
                },
                controller: _controller,
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: _onFormSubmit,
                child: Text('Add Member'),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}