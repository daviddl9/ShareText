import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/book_card_compact.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class MyPendingRequestsPageFormal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Borrow Requests'),),
      body: StreamBuilder(
          stream: Firestore.instance.collection('borrow requests').where('requesterEmail', isEqualTo: SignInPage.email).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemExtent: 210.0,
                padding: EdgeInsets.only(top: 10.0),
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]));
          }),
    );
  }

  _buildListItem(BuildContext context, DocumentSnapshot document) {
    String bookID = document.data['id'];
    String ownerEmail = document.data['ownerEmail'];
    String requesterName = document.data['requesterName'];
    String ownerName = document.data['ownerName'];
    String date = document.data['requestDate'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
          key: ValueKey(document.documentID),
          title: FutureBuilder<Book>(
            future: obtainBookFromId(bookID),
            builder: (BuildContext context, AsyncSnapshot<Book> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(),);
              }
              return PendingBorrowBookCardCompact(snapshot.data, ownerName, date.substring(0, 10), onClick: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('Actions'),
                    actions: <Widget>[
                      ButtonBar(children: <Widget>[
                        RaisedButton(color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Cancelled borrow request " + ' to ' + ownerName,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            DocumentReference ref = Firestore.instance.collection('borrow requests').document(SignInPage.email + bookID + ownerEmail);
                            Firestore.instance.runTransaction((Transaction txn) async {
                              await ref.delete();
                            });
                            //TODO work on push notifications to the user upon tapping this item.
                          },
                          child: Text('Cancel Request'),),
                        RaisedButton(child: Text('View User'),
                          color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(FadeRoute(
                                builder: (context) =>
                                    UserDetailsPageFormal(User(name: requesterName, email: ownerEmail)),
                                settings: RouteSettings(
                                    name: '/book_details_formal',
                                    isInitialRoute: false
                                )
                            ));
                          },)
                      ],),
                    ],
                  );
                });
              },);
            },
          )
      ),
    );
  }

  Future<Book> obtainBookFromId(String Id) async {
    http.Response response = await http.get("https://www.googleapis.com/books/v1/volumes/$Id")
        .catchError((resp) {});
    dynamic jsonBook = json.decode(response.body);
    return parseNetworkBook(jsonBook);
  }

  Book parseNetworkBook(jsonBook) {

    Map volumeInfo = jsonBook["volumeInfo"];
    String author = "No author";
    if(volumeInfo.containsKey("authors")) {
      author = volumeInfo["authors"][0];
    }
    String description = "No description";
    if(volumeInfo.containsKey("description")) {
      description = volumeInfo["description"];
    }
    String subtitle = "No subtitle";
    if(volumeInfo.containsKey("subtitle")) {
      subtitle = volumeInfo["subtitle"];
    }
    return new Book(
      title: jsonBook["volumeInfo"]["title"],
      url: jsonBook["volumeInfo"]["imageLinks"] != null? jsonBook["volumeInfo"]["imageLinks"]["smallThumbnail"]: "",
      id: jsonBook["id"],
      //only first author
      author: author,
      description: description,
      subtitle: subtitle,
    );
  }

}