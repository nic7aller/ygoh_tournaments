import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ygoh_tournaments/main.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key, this.user}) : super(key: key);

  final String user;

  @override
  _AccountScreenState createState() => new _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  final _userController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _passwordConfirmController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _onFormSubmit(BuildContext context) async {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      String name = _userController.text;
      String password = _passwordController.text;
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Attempting update')));
      DocumentReference doc = await _updateAdmin(widget.user);
      if (password.isEmpty) {
        await doc.updateData({'name': name});
      } else {
        await doc.updateData({'name': name, 'password': password});
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', name);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Update complete')));
    }
  }

  _updateAdmin(String oldName) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('name', isEqualTo: oldName)
        .limit(1)
        .getDocuments();
    return result.documents.elementAt(0).reference;
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
        title: new Text("Admin Account"),
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
                  labelText: 'New Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your new name';
                  }
                },
                controller: _userController,
              )
            ),
            new ListTile(
              leading: const Icon(Icons.lock),
              title:
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'h@ck3rm@n',
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
                controller: _passwordController,
              )
            ),
            new ListTile(
                leading: const Icon(Icons.lock),
                title:
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'h@ck3rm@n',
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                  },
                  obscureText: true,
                  controller: _passwordConfirmController,
                )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: () { _onFormSubmit(context); },
                child: Text('Update'),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}