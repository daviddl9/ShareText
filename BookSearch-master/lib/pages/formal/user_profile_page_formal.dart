import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/abstract/user_details_page_abstract.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_app/pages/formal/book_details_page_formal.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/user_collection_page_formal.dart';
import 'package:test_app/pages/home_page.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/collection_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:test_app/model/Book.dart';
import 'package:test_app/data/repository.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/pages/formal/chat_screen_formal.dart';
import 'dart:async';


class UserDetailsPageFormal extends StatefulWidget {
  final User user;
  UserDetailsPageFormal(this.user);
  bool isFriend = false;
  @override
  State<StatefulWidget> createState() => _UserDetailsPageFormalState();

}

class _UserDetailsPageFormalState extends AbstractUserDetailsPageState<UserDetailsPageFormal> {
  GlobalKey<ScaffoldState> key = new GlobalKey();

  /*
  Takes in a Future<List<Book>> and converts it into a widget with a horizontal
  display of widgets.
  @param name The header of the widget.
  @param color The color of the title's text.
   */
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
    Future<List<Book>> userCollection = getBooksById(IDs);
  }

  /*
  Takes in a list of book IDs and converts it into a list of books.
   */
  Future<List<Book>> getBooksById(List<String> ids) async{
    List<Book> books = [];

    for(String id in ids) {
      ParsedResponse<Book> book = await getBook(id);

      if(book.body != null) {
        books.add(book.body);
      }
    }

    return books;
  }

  /*
  Takes in the id of a book and fetches the respective information from Google Books API
  and parses it into a book object.
   */
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

  /*
  Takes in a jsonBook object and returns a Book object.
   */
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DocumentReference ref = Firestore.instance.collection('users/' + SignInPage.email + '/friends').document(widget.user.email);
    Firestore.instance.runTransaction((Transaction txn) async {
      DocumentSnapshot snapshot = await txn.get(ref);
      if (snapshot.exists) {
        setState(() {
          widget.isFriend = true;
          print('isFriend: ' + widget.isFriend.toString());
        });
      }
    });
  }

  //TODO add on to user profile page - show collection of books! onTap -> request to borrow. 
  @override
  Widget build(BuildContext context) {

    String user_email = widget.user.email;
    List<String> bookIDs = [];
    CollectionReference reference = Firestore.instance.collection('users/$user_email/booklist');
    StreamBuilder<QuerySnapshot> stream = StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users/$user_email/booklist').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Text('This user has no books.');
      },
    );

    return new Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Hero(
                    tag: widget.user.email,
                    child: CircleAvatar(child: Icon(Icons.account_circle, size: 210.0,), radius: 105.0,),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(widget.user.name, style: TextStyle(fontSize: 24.0, fontFamily: "CrimsonText")),
              SizedBox(height: 8.0,),
              Row(
                children: <Widget>[
                  Expanded(child: Text(widget.user.email, style: const TextStyle(fontSize: 16.0, fontFamily: "CrimsonText", fontWeight: FontWeight.w400),)),
                ],
              ),
              Divider(height: 32.0, color: Colors.black38,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: IconButtonText(iconData: Icons.chat, text: 'Chat', selected: false, onClick: () {
                        //TODO enable chat functionality with user
                      Navigator.of(context).push(FadeRoute(
                        builder: (context) => ChatScreen(widget.user),
                        settings: RouteSettings(name: '/chat_page_formal', isInitialRoute: false)
                      ));
                    },),
                  ),
                  Expanded(
                    child: widget.isFriend ? IconButtonText(iconData: Icons.remove_circle, selected: false, text: 'Remove Friend', onClick: () {
                      DocumentReference ref = Firestore.instance.collection('users/' + SignInPageState.currentUser.email + '/friends').document(widget.user.email);
                      DocumentReference reference = Firestore.instance.collection('users/' + widget.user.email + '/friends').document(SignInPageState.currentUser.email);
                      Firestore.instance.runTransaction((Transaction txn) async {
                        await ref.delete();
                        await reference.delete();
                      });
                      Fluttertoast.showToast(msg: 'Removed: ' + widget.user.name + ' as friend.', toastLength: Toast.LENGTH_SHORT);
                      setState(() {
                        widget.isFriend = !widget.isFriend;
                      });
                    },) : IconButtonText(iconData: Icons.group, selected: false, text: 'Add User', onClick: () {
                      // TODO add user to friendlist
                      Fluttertoast.showToast(
                        msg: "Added " + widget.user.name + " as friend.",
                        toastLength: Toast.LENGTH_LONG,
                      );
                      CollectionReference reference = Firestore.instance.collection('users/' + SignInPage.email +'/friends');
                      CollectionReference ref = Firestore.instance.collection('users/' + widget.user.email + '/friends');
                      Firestore.instance.runTransaction((Transaction txn) async {
                        await reference.document(widget.user.email).setData({'contact': widget.user.contact, 'email': widget.user.email, 'name': widget.user.name});
                        await ref.document(SignInPageState.currentUser.email).setData({'contact': SignInPage.contact, 'email': SignInPageState.currentUser.email, 'name': SignInPageState.currentUser.displayName});
                      });
                      setState(() {
                        widget.isFriend = !widget.isFriend;
                      });
                    },),
                  ),
                  Expanded(
                    child: IconButtonText(iconData: Icons.collections_bookmark, selected: false, text: 'User Collection', onClick: () {
                      Navigator.of(context).push(FadeRoute(
                          builder: (context) => UserCollectionPageFormal(widget.user),
                          settings: RouteSettings(name: '/user_collection_page', isInitialRoute: false)
                      ));
                    },),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
