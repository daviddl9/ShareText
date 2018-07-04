
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

  class UserListPage extends StatefulWidget {
    String bookID;
    UserListPage({this.bookID}); // usage: onTap: (widget.book.id) => UserListPage(widget.book.id);

    @override
    State<StatefulWidget> createState() => new UserListPageState();
  
  }

  class UserListPageState extends State<UserListPage> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Users with this book')
        ),
        body: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return FirestoreListView(documents: snapshot.data.documents);
            }),
      );
    }
  }


  // TODO make the FirestoreListView show the list of users with the book.
  class FirestoreListView extends StatelessWidget {

    final List<DocumentSnapshot> documents;

    FirestoreListView({this.documents});

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            List<String> booklist = documents[index].data['booklist'];
          });
    }

  }