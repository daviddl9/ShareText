import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/formal/book_details_page_formal.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/book_card_compact.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class BorrowRequestsPageFormal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Borrow Requests'),),
      body: StreamBuilder(
          stream: Firestore.instance.collection('borrow requests').where('ownerEmail', isEqualTo: SignInPage.email).snapshots(),
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
    String requesterName = document.data['borrowerName'];
    String requesterEmail = document.data['borrowerEmail'];
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
              return BorrowedBookCardCompact(snapshot.data, requesterName, date, isBorrowRequest: false, onClick: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('Actions'),
                    actions: <Widget>[
                      ButtonBar(children: <Widget>[
                        RaisedButton(color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Lent " +
                                  snapshot.data.title + ' to ' + requesterName,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            //TODO work on push notifications to the user upon tapping this item.
                            CollectionReference ref = Firestore.instance.collection('loans');
                            Firestore.instance.runTransaction((Transaction txn) async {
                              // Key format: borrowerEmail + bookID + ownerEmail
                              await ref.document(requesterEmail + bookID + ownerEmail).setData({
                                'borrowerEmail': requesterEmail,
                                'borrowerName': requesterName,
                                'id': bookID,
                                'loanDate': DateTime.now().toString().substring(0, 10),
                                'ownerEmail': SignInPageState.currentUser.email,
                                'ownerName': SignInPageState.currentUser.displayName
                              });
                            });
                            CollectionReference reference = Firestore.instance.collection('borrow requests');
                            Firestore.instance.runTransaction((Transaction txn) async {
                              await reference.document(requesterEmail + bookID + ownerEmail).delete();
                            }); },
                          child: Text('Approve Request'),),
                        RaisedButton(child: Text('View User'),
                          color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(FadeRoute(
                                builder: (context) =>
                                    UserDetailsPageFormal(User(name: requesterName, email: requesterEmail)),
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
      url: jsonBook["volumeInfo"]["imageLinks"] != null ? jsonBook["volumeInfo"]["imageLinks"]["smallThumbnail"]: "",
      id: jsonBook["id"],
      //only first author
      author: author,
      description: description,
      subtitle: subtitle,
    );
  }

}
