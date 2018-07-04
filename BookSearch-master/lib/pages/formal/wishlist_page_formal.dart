import 'package:flutter/material.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/pages/abstract/wishlist_page_abstract.dart';
import 'package:test_app/pages/formal/book_details_page_formal.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/stamp.dart';

/*
  This class builds a list of stamps (books) based on the user's wishlist.
 */
class WishlistCollectionFormalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WishlistCollectionFormalState();

}

class WishlistCollectionFormalState extends WishlistPageAbstractState<WishlistCollectionFormalPage> {
  @override
  Widget build(BuildContext context) {

    Widget body;


    // This block of if else statements checks if the wishlist is empty and constructs the body accordingly.
    if (wishlist.isEmpty) {
      body = Center(child: Text("You don't have any books in your wishlist."));
    } else {
      body = new ListView.builder(itemBuilder: (BuildContext context, int index){
        return new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Stamp(wishlist[index].url,),
        );
      },
        itemCount: wishlist.length,
        scrollDirection: Axis.horizontal,
      );
    }

    // Maps the list to a list of stamps.
    body = new GridView.extent(
      maxCrossAxisExtent: 150.0,
      mainAxisSpacing: 20.0,
      // map button to the book details page.
      children: wishlist.map((Book book)=> new Stamp(book.url, width: 90.0, onClick: (){
        Navigator.of(context).push(
            new FadeRoute(
              builder: (BuildContext context) => new BookDetailsPageFormal(book),
              settings: new RouteSettings(name: '/book_detais_formal', isInitialRoute: false),
            ));
      },)).toList(),

    );

    body = new Container(
      padding: const EdgeInsets.all(16.0),
      child: body,
      color: new Color(0xFFF5F5F5),
    );

    // Returns a widget with the body built.
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("My Wishlist", style: const TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: new IconThemeData(color: Colors.black),
      ),
      body: body,
    );

  }

}