import 'package:flutter/material.dart';
import 'package:test_app/data/repository.dart';
import 'package:test_app/model/Book.dart';
import 'package:test_app/widgets/book_card_compact.dart';

/*
  This class is a helper class to build the wishlist page. It fetches the
  wishlist from the database for the wishlist widget to use.
 */
abstract class WishlistPageAbstractState<T extends StatefulWidget> extends State<T> {


  List<Book> wishlist = new List();


  @override
  void initState() {
    super.initState();
    Repository.get().getWishlist()
        .then((books) {
      setState(() {
        wishlist = books;
      });
    });
  }


}