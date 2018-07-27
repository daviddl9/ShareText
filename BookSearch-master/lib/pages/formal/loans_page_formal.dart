import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/formal/book_details_page_formal.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/book_card_compact.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class LoansPageFormal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My loans'),),
      body: StreamBuilder(
          stream: Firestore.instance.collection('loans').where('borrowerEmail', isEqualTo: SignInPage.email).snapshots(),
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
    String ownerName = document.data['ownerName'];
    String date = document.data['loanDate'];
    String borrowerEmail = document.data['borrowerEmail'];
    String borrowerName = document.data['borrowerName'];
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
              return BorrowedBookCardCompact(snapshot.data, ownerName, date, isBorrowRequest: true, onClick: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('Actions'),
                    actions: <Widget>[
                      ButtonBar(children: <Widget>[
                        RaisedButton(color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Returned " +
                                  snapshot.data.title + ' to ' + ownerEmail,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            CollectionReference ref = Firestore.instance.collection('return requests');
                            Firestore.instance.runTransaction((Transaction txn) async {
                              await ref.document(borrowerEmail+bookID+ownerEmail).setData({
                                'id': bookID,
                                'ownerEmail': ownerEmail,
                                'ownerName': ownerName,
                                'loanDate': date,
                                'borrowerName': borrowerName,
                                'borrowerEmail': borrowerEmail
                              });
                            });
                            //TODO work on push notifications to the user upon tapping this item.
                          },
                          child: Text('Return'),),
                        RaisedButton(child: Text('Details'),
                          color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(FadeRoute(
                                builder: (context) =>
                                    BookDetailsPageFormal(snapshot.data),
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