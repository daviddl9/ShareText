import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/data/repository.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/widgets/collection_preview.dart';
import 'package:test_app/widgets/user_card_compact.dart';
import 'dart:convert';

class MyNotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notifications'),),
      body: StreamBuilder(
          stream: Firestore.instance.collection('return requests').where('ownerEmail', isEqualTo: SignInPageState.currentUser.email).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator()); //This might cause some bugs, take note.
            }
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: EdgeInsets.only(top: 10.0),
//                itemExtent: 360.0,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index])
            );
          }),
    );
  }

  _buildListItem(BuildContext context, DocumentSnapshot document) {
    //Retrieving data from the database doesn't work, perhaps we should try creating
    // a new collection in the database to work around this matter.
    String bookID = document.data['id'];
    String borrowerEmail = document.data['borrowerEmail'];
    String borrowerName = document.data['borrowerName'];
    String ownerEmail = document.data['ownerEmail'];
    String ownerName = document.data['ownerName'];

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        key: ValueKey(document.documentID),
        title: FutureBuilder<Book>(
          future: obtainBookFromId(bookID),
          builder: (BuildContext context, AsyncSnapshot<Book> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(),);
            }
            return UserCardCompact(borrowerName: borrowerEmail, book: snapshot.data, ownerEmail: ownerEmail, borrowerEmail: borrowerEmail);
          },
        ),
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