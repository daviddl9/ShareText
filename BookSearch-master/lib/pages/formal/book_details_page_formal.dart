import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:test_app/data/repository.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/pages/abstract/book_details_page_abstract.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/user_list_formal.dart';
import 'package:test_app/utils/utils.dart';



class BookDetailsPageFormal extends StatefulWidget {


  BookDetailsPageFormal(this.book);

  final Book book;

  @override
  State<StatefulWidget> createState() => new _BookDetailsPageFormalState();

}


class _BookDetailsPageFormalState extends AbstractBookDetailsPageState<BookDetailsPageFormal> {
  GlobalKey<ScaffoldState> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: new AppBar(
        title: new Text("My Collection"),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      body: new SingleChildScrollView(
        child: new Padding(
          padding: const EdgeInsets.all(32.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Center(
                  child: new Hero(
                    tag: widget.book.id,
                    child: new Image.network(widget.book.url, fit: BoxFit.cover,),
                  ),
                ),
              ),
              new SizedBox(height: 16.0,),
              new Text(widget.book.title, style: const TextStyle(fontSize: 24.0, fontFamily: "CrimsonText"),),
              new SizedBox(height: 8.0,),
              new Text("${widget.book.author}", style: const TextStyle(fontSize: 16.0, fontFamily: "CrimsonText", fontWeight: FontWeight.w400),),
              new Divider(height: 32.0, color: Colors.black38,),
              new Row(
                children: <Widget>[
                  new Expanded(
                      child: new IconButtonText(
                        onClick: (){
                          //TODO may need to remove this part
                          Navigator.of(context).push(
                            FadeRoute(
                              builder: (context) => UserListPage(widget.book.id),
                              settings: RouteSettings(
                                name: '/user_list_page',
                                isInitialRoute: false
                              )
                            )
                          );
                          // TODO figure out how to search users and how to manipulate the data. 
                        },
                        iconData: Icons.people,
                        text: "Search users",
                        selected: false,
                      ),
                  ),
                  new Expanded(
                    child: new IconButtonText(
                      onClick: (){
                        setState(() {
                          String preText, postText;
                          if (widget.book.wishlisted) {
                            preText = "Removed:";
                            postText = "from";
                          } else {
                            preText = "Added:";
                            postText = "to";
                          }
                          widget.book.wishlisted = !widget.book.wishlisted;
                          Repository.get().updateBook(widget.book);
                          key.currentState.showSnackBar(new SnackBar(content: new Text("$preText ${widget.book.title} $postText wishlist")));
                        });
                      },
                      iconData: widget.book.wishlisted? Icons.remove : Icons.bookmark,
                      text: widget.book.wishlisted? "Remove" : "Add to wishlist",
                      selected: widget.book.wishlisted,
                    ),
                  ),
                  new Expanded(
                    child: new IconButtonText(
                      // Update the user's book collection on both firestore and on the remote device.
                      onClick: (){
                        String email = SignInPage.email;
                        // Update users collection first.
                        Firestore.instance.runTransaction((Transaction transaction) async {
                          CollectionReference reference = Firestore.instance.collection('users/$email' + '/booklist');
                          if (widget.book.starred) {
                            // we use setData to specify the id of the collection we want to add into.
                            await reference.document(widget.book.id).setData(
                                {'id': widget.book.id, 'isAvailable': true});
                          } else {
                            await reference.document(widget.book.id).delete();
                          }
                        });
                        // Then update book collection.
                        Firestore.instance.runTransaction((Transaction transaction) async {
                          CollectionReference reference = Firestore.instance.collection('books');
                          if (widget.book.starred) {
                            await reference.document(widget.book.id).setData({'id': widget.book.id, 'isAvailable': true, 'ownerEmail': SignInPageState.currentUser.email, 'user': {
                              'email' : SignInPageState.currentUser.email,
                              'name' : SignInPageState.currentUser.displayName,
                              'contact' : SignInPage.contact
                            }});
                          } else {
                            await reference.document(widget.book.id).delete();
                          }
                        });
                        setState(() {
                          String preText, postText;
                          widget.book.starred = !widget.book.starred;
                          if (widget.book.starred) {
                            preText = "Added:";
                            postText = "to";
                          } else {
                            preText = "Removed:";
                            postText = "from";
                          }
                          key.currentState.showSnackBar(new SnackBar(content: new Text("$preText ${widget.book.title} $postText collection")));
                          Repository.get().updateBook(widget.book);
                        });
                      },
                      iconData: widget.book.starred? Icons.remove : Icons.add,
                      text: widget.book.starred? "Remove" : "My Collection",
                      selected: widget.book.starred,
                    ),
                  ),
                ],
              ),
              new Divider(height: 32.0, color: Colors.black38,),
              new Text("Description", style: const TextStyle(fontSize: 20.0, fontFamily: "CrimsonText"),),
              new SizedBox(height: 8.0,),
              new Text(widget.book.description, style: const TextStyle(fontSize: 16.0),),
            ],
          ),
        ),
      ),
    );
  }
  }


class IconButtonText extends StatelessWidget {



  IconButtonText({@required this.onClick, @required this.iconData, @required this.text, this.selected});


  final VoidCallback onClick;

  final IconData iconData;
  final String text;

  bool selected = false;

  final Color selectedColor = new Color(0xff283593);

  @override
  Widget build(BuildContext context) {
    return new InkResponse(
      onTap: onClick,
      child: new Column(
        children: <Widget>[
          new Icon(iconData, color: selected? selectedColor: Colors.black,),
          new Text(text, style: new TextStyle(color: selected? selectedColor: Colors.black),)
        ],
      ),
    );
  }

}