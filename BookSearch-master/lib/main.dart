import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_app/pages/universal/collection_page.dart';
import 'package:test_app/pages/formal/stamp_collection_page_formal.dart';
import 'package:test_app/pages/home_page.dart';
import 'package:test_app/pages/material/search_book_page_material.dart';
import 'package:test_app/pages/formal/search_book_page_formal.dart';
import 'package:test_app/pages/material/stamp_collection_page_material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:test_app/redux/app_state.dart';
import 'package:test_app/redux/reducers.dart';
import 'dart:convert' show json;
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_app/pages/material/wishlist_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  final Store<AppState> store = new Store(readBookReducer, initialState: AppState.initState());
  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store:store,
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Book search',
        theme: new ThemeData(
          primaryColor: new Color(0xFF0F2533),
        ),
        routes: {
          '/': (BuildContext context) => new HomePage(),
          '/search_material': (BuildContext context) => new SearchBookPage(),
          '/search_formal': (BuildContext context) => new SearchBookPageNew(),
          '/collection': (BuildContext context) => new CollectionPage(),
          '/stamp_collection_material': (BuildContext context) => new StampCollectionPage(),
          '/stamp_collection_formal': (BuildContext context) => new StampCollectionFormalPage(),
          '/wishlist_page': (BuildContext context) => new WishlistPage()
        },
      ),
    );
  }

}
//
//GoogleSignIn _googleSignIn = new GoogleSignIn(
//  scopes: <String>[
//    'email',
//    'https://www.googleapis.com/auth/contacts.readonly',
//  ],
//);
//
//Widget signIn() {
//    return new MaterialApp(
//      title: 'Google Sign In',
//      home: new SignInDemo(),
//    );
//}
//
//class SignInDemo extends StatefulWidget {
//  @override
//  State createState() => new SignInDemoState();
//}
//
//class SignInDemoState extends State<SignInDemo> {
//  GoogleSignInAccount _currentUser;
//  String _contactText;
//
//  @override
//  void initState() {
//    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        _currentUser = account;
//      });
//      if (_currentUser != null) {
//        _handleGetContact();
//      }
//    });
//    _googleSignIn.signInSilently();
//  }
//
//  Future<Null> _handleGetContact() async {
//    setState(() {
//      _contactText = "Loading contact info...";
//    });
//    final http.Response response = await http.get(
//      'https://people.googleapis.com/v1/people/me/connections'
//          '?requestMask.includeField=person.names',
//      headers: await _currentUser.authHeaders,
//    );
//    if (response.statusCode != 200) {
//      setState(() {
//        _contactText = "People API gave a ${response.statusCode} "
//            "response. Check logs for details.";
//      });
//      print('People API ${response.statusCode} response: ${response.body}');
//      return;
//    }
//    final Map<String, dynamic> data = json.decode(response.body);
//    final String namedContact = _pickFirstNamedContact(data);
//    setState(() {
//      if (namedContact != null) {
//        _contactText = "I see you know $namedContact!";
//      } else {
//        _contactText = "No contacts to display.";
//      }
//    });
//  }
//
//  String _pickFirstNamedContact(Map<String, dynamic> data) {
//    final List<dynamic> connections = data['connections'];
//    final Map<String, dynamic> contact = connections?.firstWhere(
//          (dynamic contact) => contact['names'] != null,
//      orElse: () => null,
//    );
//    if (contact != null) {
//      final Map<String, dynamic> name = contact['names'].firstWhere(
//            (dynamic name) => name['displayName'] != null,
//        orElse: () => null,
//      );
//      if (name != null) {
//        return name['displayName'];
//      }
//    }
//    return null;
//  }
//
//  Future<Null> _handleSignIn() async {
//    try {
//      await _googleSignIn.signIn();
//    } catch (error) {
//      print(error);
//    }
//  }
//
//  Future<Null> _handleSignOut() async {
//    _googleSignIn.disconnect();
//  }
//
//  Widget _buildBody() {
//    if (_currentUser != null) {
//      return new Column(
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
//        children: <Widget>[
//          new ListTile(
//            leading: new GoogleUserCircleAvatar(
//              identity: _currentUser,
//            ),
//            title: new Text(_currentUser.displayName),
//            subtitle: new Text(_currentUser.email),
//          ),
//          const Text("Signed in successfully."),
//          new Text(_contactText),
//          new RaisedButton(
//            child: const Text('SIGN OUT'),
//            onPressed: _handleSignOut,
//          ),
//          new RaisedButton(
//            child: const Text('REFRESH'),
//            onPressed: _handleGetContact,
//          ),
//        ],
//      );
//    } else {
//      return new Column(
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
//        children: <Widget>[
//          const Text("You are not currently signed in."),
//          new RaisedButton(
//            child: const Text('SIGN IN'),
//            onPressed: _handleSignIn,
//          ),
//        ],
//      );
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//        appBar: new AppBar(
//          title: const Text('Google Sign In'),
//        ),
//        body: new ConstrainedBox(
//          constraints: const BoxConstraints.expand(),
//          child: _buildBody(),
//        ));
//  }
//}

