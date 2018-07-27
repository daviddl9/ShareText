import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/data/repository.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/universal/book_notes_page.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/BookCard.dart';
import 'package:test_app/widgets/book_card_compact.dart';
import 'package:test_app/widgets/book_card_minimalistic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';



var rng = Random(5);
final MAX_INTEGER = 0xffffffff;
//TODO implement a search user function to return a listview of
abstract class AbstractSearchUserState<T extends StatefulWidget> extends State<T> {
  List<User> users = new List();

  final subject = new PublishSubject<String>();

  bool isLoading = false;

  GlobalKey<ScaffoldState> userKey = new GlobalKey();

  void _textChanged(String text) {
    _clearList();
    if(text.isEmpty) {
      setState((){isLoading = false;});
      _clearList();
      return;
    }
    // TODO: Init userlist first!
    setState((){isLoading = true;});
    _clearList();
    Firestore.instance.collection('users').where('name', isEqualTo: text).snapshots().map((snapshot) => snapshot.documents).map((documents) {
      for (DocumentSnapshot ds in documents) {
        User newUser = User(name: ds['name'], email: ds['email'], contact: ds['contact']);
        users.add(newUser);
      }
      setState(() {
        isLoading = false;
      });
    });
  }


  void _clearList() {
    setState(() {
      users.clear();
    });
  }

  @override
  void dispose() {
    subject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subject.stream.debounce(new Duration(milliseconds: 600)).listen(_textChanged);
  }

}

Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
  return ListTile(
    key: ValueKey(document.documentID),
    title: Container(
      decoration: BoxDecoration(
          border: Border.all(color: Color(0x80000000)),
          borderRadius: BorderRadius.circular(5.0)
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(document['name']),
          ),
          CircleAvatar(backgroundColor: Color(rng.nextInt(MAX_INTEGER)), child: Text(document['name'][0]),)
        ],
      ),
    ),

  );
}