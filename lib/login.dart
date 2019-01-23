import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ygoh_tournaments/home.dart';
import 'package:ygoh_tournaments/main.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.prefs}) : super(key: key);

  final SharedPreferences prefs;

  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _userController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _onFormSubmit() async {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      String name = _userController.text;
      String password = _passwordController.text;
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Attempting login')));
      Map<String, dynamic> data = await _checkExistence(name, password);
      if (data != null) {
        bool status = data['admin'];
        SharedPreferences prefs = widget.prefs;
        if (prefs == null) {
          prefs = await SharedPreferences.getInstance();
        }
        await prefs.setString('current_user', name);
        await prefs.setBool('admin_status', status);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(user: name, admin: status)),
                (Route < dynamic > route) => false
        );
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('User not found')));
      }
    }
  }

  _checkExistence(String name, String password) async {
    Map<String, dynamic> data;
    await Firestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .where('password', isEqualTo: password)
        .limit(1)
        .getDocuments()
        .then((result) {
          if (result.documents.length == 1) {
            data = result.documents[0].data;
          }
        }
    );
    return data;
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
        title: new Text("User Login"),
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
                    return 'Please enter your name';
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
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your pasword';
                  }
                },
                obscureText: true,
                controller: _passwordController,
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: _onFormSubmit,
                child: Text('Login'),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}