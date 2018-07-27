import 'dart:async';
import 'dart:convert';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/formal/book_details_page_formal.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/book_card_compact.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/data/repository.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/widgets/collection_preview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';

class UserCollectionPageFormal extends StatefulWidget {

  UserCollectionPageFormal(this.user);
  final User user;

  @override
  State<StatefulWidget> createState() => UserCollectionPageFormalState();
}

class UserCollectionPageFormalState extends State<UserCollectionPageFormal> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print(message);
      },
      onResume: (Map<String, dynamic> message) {
        print(message);
      },
    );
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name + '\'s books'),),
      body:
      StreamBuilder(
          stream: Firestore.instance.collection('books').where('ownerEmail', isEqualTo: widget.user.email).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator()); //This might cause some bugs, take note.
            }
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: EdgeInsets.only(top: 10.0),
                itemExtent: 210.0,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index])
            );
          }),
    );
  }

  // Steps: Get document id -> generate book -> generate bookCard
  // onTap -> 2 options: request to borrow or book details.
  _buildListItem(BuildContext context, DocumentSnapshot document) {
    //Retrieving data from the database doesn't work, perhaps we should try creating
    // a new collection in the database to work around this matter.
    String bookID = document.data['id'];
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
              return BookCardCompact(snapshot.data, onClick: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('Actions'),
                    actions: <Widget>[
                      ButtonBar(children: <Widget>[
                        RaisedButton(color: Colors.red,
                          textColor: Colors.white,
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Requested to borrow " +
                                  snapshot.data.title + ' from ' + widget.user.name,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            CollectionReference ref = Firestore.instance.collection('borrow requests');
                            Firestore.instance.runTransaction((Transaction txn) async {
                              // Key format: requester email + bookid + owner email
                              await ref.document(SignInPage.email + bookID + widget.user.email).setData({'id': snapshot.data.id, 'ownerEmail': widget.user.email, 'ownerName': widget.user.name, 'requestDate': DateTime.now().toString().substring(0, 10), 'borrowerEmail': SignInPage.email, 'borrowerName': SignInPage.username});
//                              await ref.add({'id': snapshot.data.id, 'ownerEmail': widget.user.email, 'requestDate': DateTime.now().toString().substring(0, 10), 'requesterEmail': SignInPage.email, 'requesterName': SignInPage.username});
                            });
                            //TODO work on push notifications to the user upon tapping this item.
                          },
                          child: Text('Request to Borrow'),),
                        RaisedButton(child: Text('Book Details'),
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


  Widget collectionPreview(Color color, String name, Future<List<Book>> bookCollection) {
    return new FutureBuilder<List<Book>>(
      future: bookCollection,
      builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
        List<Book> books = [];
        if(snapshot.data != null) books = snapshot.data;
        return new CollectionPreview(
          books: books,
          color: color,
          title: name,
          loading: snapshot.data == null,
        );
      },
    );
  }

  getCollectionItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<String> IDs = snapshot.data.documents.map((doc) => doc.documentID).toList();
//    Future<List<Book>> userCollection = getBooksById(IDs);
  return IDs.map((id) => ListTile());
  }

  Future<Book> obtainBookFromId(String Id) async {
      http.Response response = await http.get("https://www.googleapis.com/books/v1/volumes/$Id")
          .catchError((resp) {});
      dynamic jsonBook = json.decode(response.body);
      return parseNetworkBook(jsonBook);
  }

  Future<List<Book>> getBooksById(List<String> ids) async {
    List<Book> books = [];

    for(String id in ids) {
      ParsedResponse<Book> book = await getBook(id);

      if(book.body != null) {
        books.add(book.body);
      }
    }

    return books;
  }

  Future<ParsedResponse<Book>> getBook(String id) async {
    http.Response response = await http.get("https://www.googleapis.com/books/v1/volumes/$id")
        .catchError((resp) {});
    if(response == null) {
      return new ParsedResponse(NO_INTERNET, null);
    }

    //If there was an error return null
    if(response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }

    dynamic jsonBook = json.decode(response.body);

    Book book = parseNetworkBook(jsonBook);

    return new ParsedResponse(response.statusCode, book);
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
