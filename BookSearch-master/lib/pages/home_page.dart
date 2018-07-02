import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:test_app/data/repository.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/utils/index_offset_curve.dart';
import 'package:test_app/widgets/collection_preview.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

GoogleSignInAccount _currentUser;

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

Future<Null> _handleSignIn() async {
  try {
    await _googleSignIn.signIn();
    print("Logged In");
  } catch (error) {
    print(error);
  }
}

  Future<Null> _handleSignOut() async {
    _googleSignIn.disconnect();
    print("Logged out");
  }


class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {


  AnimationController cardsFirstOpenController;


  String interfaceType = "formal";

  bool init = true;

  @override
  void initState() {
    super.initState();
    cardsFirstOpenController = new AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

    Repository.get().init().then((it){
      setState((){
        init = false;
      });
    });
    cardsFirstOpenController.forward(from: 0.2);
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
                accountName: Text('David Livingston', style: TextStyle(color: Colors.black87)),
                accountEmail: Text('ddl.tdh@gmail.com', style: TextStyle(color: Colors.black87)),
                currentAccountPicture: GestureDetector(
                  child: CircleAvatar(
                    child: Text('DL'),
                    radius: 5.0,
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
              )
            ],
          ),
        ),
      body: init? new Container(): new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            actions: <Widget>[
              new IconButton(icon: new Icon(Icons.search), onPressed: () {Navigator.pushNamed(context, '/search_$interfaceType');},),
//              new IconButton(icon: new Icon(Icons.collections), onPressed: () {Navigator.pushNamed(context, '/stamp_collection_$interfaceType');},),
              new IconButton(icon: (_currentUser == null) ? Icon(Icons.group) : Icon(Icons.exit_to_app), onPressed: () {_currentUser == null ? _handleSignIn() : _handleSignOut();},)
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