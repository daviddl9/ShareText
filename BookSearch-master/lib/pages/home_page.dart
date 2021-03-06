import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:test_app/data/repository.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/utils/index_offset_curve.dart';
import 'package:test_app/widgets/collection_preview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';


class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
//
//
  AnimationController cardsFirstOpenController;
//
//
  String interfaceType = "formal";
//
  bool init = true;
//
  @override
  void initState() {
    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        _currentUser = account;
//      });
//    });
    cardsFirstOpenController = new AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
//
    Repository.get().init().then((it){
      setState((){
        init = false;
      });
    });
    cardsFirstOpenController.forward(from: 0.2);
////    _googleSignIn.signInSilently();
  }


  @override
  void dispose() {
    cardsFirstOpenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(SignInPage.username, style: TextStyle(color: Colors.black87)),
                accountEmail: Text(SignInPage.email, style: TextStyle(color: Colors.black87)),
                currentAccountPicture: GestureDetector(
                  child: CircleAvatar(
                    child: Text(SignInPage.username[0], style: TextStyle(fontSize:40.0)),
                    radius: 2.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent
                ),
              ),
              ListTile(
                title: Text('My Wishlist'),
                trailing: Icon(Icons.book),
                onTap: () => Navigator.of(context).pushNamed('/wishlist_page'),
              ),
              ListTile(
                title: Text('My Library'),
                trailing: Icon(Icons.library_books),
                onTap: () => Navigator.of(context).pushNamed('/collection'),
              ),
              ListTile(
                title: Text('Edit Profile'),
                trailing: Icon(Icons.edit),
                onTap: () => Navigator.of(context).pushNamed('/edit_profile'),
              ),
              ListTile(
                title: Text('Notifications'),
                trailing: Icon(Icons.notifications),
                onTap: () => Navigator.of(context).pushNamed('/my_notifications_page'),
              ),
              ListTile(
                title: Text('My Chats'),
                trailing: Icon(Icons.chat),
                onTap: () => Navigator.of(context).pushNamed('/my_chats_list_page') //TODO implement chat page
              ),
              ListTile(
                title: Text('My Friends'),
                trailing: Icon(Icons.people_outline),
                onTap: () => Navigator.of(context).pushNamed('/friends_page'),
              ),
              ListTile(
                title: Text('My Loans'),
                trailing: Icon(Icons.format_list_bulleted),
                onTap: () => Navigator.of(context).pushNamed('/loans_page'),
              ),
              ListTile(
                title: Text('Borrow Requests'),
                trailing: Icon(Icons.library_add),
                onTap: () => Navigator.of(context).pushNamed('/borrow_requests_page')
              ),
              ListTile(
                title: Text('My Pending Requests'),
                trailing: Icon(Icons.watch_later),
                onTap: () => Navigator.of(context).pushNamed('/my_pending_requests_page')
              ),
              ListTile(
                title: Text('My Loaned out Items'),
                trailing: Icon(Icons.receipt),
                onTap: () => Navigator.of(context).pushNamed('/my_loaned_out_items_page'),
              ),
              ListTile(
                title: Text('Log out'),
                trailing: Icon(Icons.exit_to_app),
                onTap: () {
                  SignInPage.handleSignOut();
                  Navigator.of(context).popAndPushNamed('/');
                }
              )
            ],
          ),
        ),
      body: init? new Container(): new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            actions: <Widget>[
              new IconButton(icon: Icon(Icons.group), onPressed: () {Navigator.of(context).pushNamed('/search_users_page');},),
              new IconButton(icon: new Icon(Icons.search), onPressed: () {Navigator.pushNamed(context, '/search_$interfaceType');},),
//              new IconButton(icon: new Icon(Icons.collections), onPressed: () {Navigator.pushNamed(context, '/stamp_collection_$interfaceType');},),
              new IconButton(icon: Icon(Icons.exit_to_app), onPressed: () {
                SignInPage.handleSignOut();
                Navigator.of(context).popAndPushNamed('/');
              })
            ],
            backgroundColor: Colors.white,
            elevation: 2.0,
            iconTheme: new IconThemeData(color: Colors.black),
            floating: true,
            forceElevated: true,
          ),
          new SliverList(delegate: new SliverChildListDelegate(
            [
              wrapInAnimation(myCollection(), 0),
              wrapInAnimation(myWishlist(), 1),
              wrapInAnimation(collectionPreview(new Color(0xffffffff), "Biographies", ["wO3PCgAAQBAJ","_LFSBgAAQBAJ","8U2oAAAAQBAJ", "yG3PAK6ZOucC"]), 2),
              wrapInAnimation(collectionPreview(new Color(0xffffffff), "Fiction", ["OsUPDgAAQBAJ", "3e-dDAAAQBAJ", "-ITZDAAAQBAJ","rmBeDAAAQBAJ", "vgzJCwAAQBAJ"]), 3),
              wrapInAnimation(collectionPreview(new Color(0xffffffff), "Mystery & Thriller", ["1Y9gDQAAQBAJ", "Pz4YDQAAQBAJ", "UXARDgAAQBAJ"]), 4),
              wrapInAnimation(collectionPreview(new Color(0xffffffff), "Science Fiction", ["JMYUDAAAQBAJ","PzhQydl-QD8C", "nkalO3OsoeMC", "VO8nDwAAQBAJ", "Nxl0BQAAQBAJ"]), 5),
            ],
          ))
        ],
      )
    );
  }

  Widget wrapInAnimation(Widget child, int index) {
    Animation offsetAnimation = new CurvedAnimation(parent: cardsFirstOpenController, curve: new IndexOffsetCurve(index));
    Animation fade = new CurvedAnimation(parent: offsetAnimation, curve: Curves.ease);
    return new SlideTransition(
        position: new Tween<Offset>(begin: new Offset(0.5, 0.0), end: new Offset(0.0, 0.0)).animate(fade),
        child: new FadeTransition(
          opacity: fade,
          child: child,
        )
    );
  }


  Widget collectionPreview(Color color, String name, List<String> ids) {
    return new FutureBuilder<List<Book>>(
      future: Repository.get().getBooksByIdFirstFromDatabaseAndCache(ids),
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


  Widget myCollection() {
    return new FutureBuilder<List<Book>>(
      future: Repository.get().getFavoriteBooks(),
      builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
        List<Book> books = [];
        if(snapshot.data != null) books = snapshot.data;
        if(books.isEmpty) {
          return new Container();
        }
        return new CollectionPreview(
          books: books,
          //color: new Color(0xffFC96BC),
          color: new Color(0xffffffff),
          title: "My Collection",
          loading: snapshot.data == null,
        );
      },
    );
  }

  Widget myWishlist() {
    return new FutureBuilder<List<Book>>(
      future: Repository.get().getWishlist(),
      builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
        List<Book> books = [];
        if (snapshot.data != null) books = snapshot.data;
        if (books.isEmpty) {
          return new Container();
        }
        return new CollectionPreview(
            books: books,
            title: "My Wishlist",
            color: new Color(0xffffffff),
            loading: snapshot.data == null,
        );
      }
    );
  }


}