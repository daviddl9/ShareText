import 'dart:async';
import 'dart:convert' show json;
import 'package:fluttertoast/fluttertoast.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

GoogleSignIn googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/gmail.compose'
  ],
);

Future<Null> _handleSignIn() async {
  try {
    await googleSignIn.signIn();
    Fluttertoast.showToast(
        msg: "Logged In Successfully.",
        toastLength: Toast.LENGTH_SHORT,
    );
  } catch (error) {
    print(error);
  }
}

class SignInPage extends StatefulWidget {
  static String email;
  static String username;

  static Future<Null> handleSignOut() async {
    googleSignIn.disconnect();
    Fluttertoast.showToast(msg: "Logged Out Successfully.", toastLength: Toast.LENGTH_SHORT);
  }

  @override
  State<StatefulWidget> createState() => SignInPageState();

}

class SignInPageState extends State<SignInPage> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        SignInPage.email = _currentUser.email;
        SignInPage.username = _currentUser.displayName;
      });
    });
    googleSignIn.signInSilently();
  }


  @override
  Widget build(BuildContext context) {
    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 58.0,
          onPressed: () {
            setState(() async {
              await _handleSignIn();
              Navigator.of(context).pushNamed('/home_page');
            });
//            _handleSignIn();
//            Navigator.of(context).pushNamed('/home_page');
          },
          color: Colors.lightBlueAccent,
          child: Text('Log In', style: TextStyle(color: Colors.white, fontSize: 20.0)),
        ),
      ),
    );
    String email = SignInPage.email;
    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 58.0,
          onPressed: () {
            _handleSignIn();
            Firestore.instance.runTransaction((Transaction transaction) async {
              DocumentReference reference = Firestore.instance.document('users/$email');
              DocumentSnapshot ds = await transaction.get(reference);
              if (ds.exists) {
                Fluttertoast.showToast(msg: 'An account with this email already exists, please log in instead.', toastLength: Toast.LENGTH_LONG);
              } else {
                CollectionReference reference = Firestore.instance.collection('users');
                await reference.add({"email":SignInPage.email, "name":SignInPage.username});
                Navigator.of(context).pushNamed('edit_profile');
              }
            });
          },
          child: Text('Sign up', style: TextStyle(color: Colors.black, fontSize: 20.0)),
        ),
      ),
    );

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/ShareText.jpg'),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
//      appBar: AppBar(title: Text('ShareText', style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold)), centerTitle: true),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
//            email,
            SizedBox(height: 8.0),
//            password,
//            SizedBox(height: 24.0),
            loginButton,
//            SizedBox(height: 12.0),
            signUpButton
          ],
        ),
      ),
    );
  }

}