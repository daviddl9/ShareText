import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:fluttertoast/fluttertoast.dart';

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String> [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]
);

GoogleSignInAccount _currentUser;

class EditProfilePage extends StatefulWidget {
  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        email = _currentUser.email;
        name = _currentUser.displayName;
      });
    });
    _googleSignIn.signInSilently();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  String email;
  String name;
  String num;

  void _submit() {
    final form = formKey.currentState;
    
    Firestore.instance.runTransaction((Transaction transaction) async {
//      CollectionReference reference = Firestore.instance.collection('users');
//      await reference.add({"email":_email, "name":_name, "contact":_num});

        DocumentReference reference = Firestore.instance.document('users/$email');
        Firestore.instance.runTransaction((Transaction txn) async {
          DocumentSnapshot ds = await txn.get(reference);
          if (ds.exists) {
            await txn.update(reference, <String, dynamic> {"name":name, "email":email, "contact":num});
          } else {
            CollectionReference reference = Firestore.instance.collection('users');
            await reference.add({"email":email, "name":name, "contact":num});
          }
        });

    });

    if (form.validate()) {
      form.save();
    }
    Fluttertoast.showToast(
      msg: "Profile saved successfully, please logout and login again to update changes.",
      toastLength: Toast.LENGTH_LONG,
    );

    Navigator.of(context).pushNamed('/home_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Edit profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Your name',
                    icon: Icon(Icons.person),
                ),
                initialValue: SignInPageState.currentUser.displayName,
                onSaved: (val) => name = val,
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: 'Phone',
                  hintText: 'Enter mobile number'
                ),
                onSaved: (val) => num = val,
                initialValue: SignInPage.contact,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Your email',
                    icon: Icon(Icons.email)
                ),
                initialValue: SignInPageState.currentUser.email,
                validator: (val) =>
                !val.contains('@') ? 'Not a valid email.' : null,
                onSaved: (val) => email = val,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: _submit,
                  child: Text('Update profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}