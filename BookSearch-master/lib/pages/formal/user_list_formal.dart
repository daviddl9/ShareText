import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'package:test_app/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

  /*
  This class represents the page displayed when the user taps the "Search Users" button.
  It takes in the book ID of the book searched by the user and shows a list of users with
  this book, as filtered by the 'where('id', isEqualTo: bookID).
   */
  class UserListPage extends StatelessWidget {
    final String bookID;
    UserListPage(this.bookID);

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Scaffold(
        appBar: AppBar(title: Text('Users with this Book')),
        body: StreamBuilder(
          stream: Firestore.instance.collection('books').where('id', isEqualTo: bookID).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator()); //This might cause some bugs, take note.
            }
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: EdgeInsets.only(top: 10.0),
                itemExtent: 55.0,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index])
            );
          },
        ),
      );
    }

  _buildListItem(BuildContext context, DocumentSnapshot document) {
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
                child: Text(document['user']['name']),
              ),
              CircleAvatar(
                backgroundColor: Colors.amber,
                child: Text(document['user']['name'][0]),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
              FadeRoute(
                  builder: (context) =>
                      UserDetailsPageFormal(User(name: document['user']['name'], email: document['user']['email'], contact: document['user']['contact'])),
                  settings: RouteSettings(
                      name: '/user_details_page',
                      isInitialRoute: false
                  )
              )
          );
        }
      );

  }

  }