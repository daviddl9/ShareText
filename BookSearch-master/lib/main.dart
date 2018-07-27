import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_app/pages/formal/borrow_requests_page.dart';
import 'package:test_app/pages/formal/edit_profile.dart';
import 'package:test_app/pages/formal/friends_list_page.dart';
import 'package:test_app/pages/formal/loans_page_formal.dart';
import 'package:test_app/pages/formal/my_loaned_out_items_page.dart';
import 'package:test_app/pages/formal/my_notifications_page.dart';
import 'package:test_app/pages/formal/pending_requests_page.dart';
import 'package:test_app/pages/formal/search_user_page_formal.dart';
import 'package:test_app/pages/formal/sign_in_page_formal.dart';
import 'package:test_app/pages/formal/user_list_formal.dart';
import 'package:test_app/pages/formal/wishlist_page_formal.dart';
import 'package:test_app/pages/universal/collection_page.dart';
import 'package:test_app/pages/formal/stamp_collection_page_formal.dart';
import 'package:test_app/pages/home_page.dart';
import 'package:test_app/pages/material/search_book_page_material.dart';
import 'package:test_app/pages/formal/search_book_page_formal.dart';
import 'package:test_app/pages/material/stamp_collection_page_material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:test_app/redux/app_state.dart';
import 'package:test_app/redux/reducers.dart';
import 'package:test_app/pages/formal/chats_list_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  final Store<AppState> store = new Store(readBookReducer, initialState: AppState.initState());
  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store:store,
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Book search',
        theme: new ThemeData(
          primaryColor: new Color(0xFF0F2533),
        ),
        routes: {
          '/': (BuildContext context) => SignInPage(),
          '/home_page': (BuildContext context) => new HomePage(),
          '/search_users_page': (BuildContext context) => new SearchUserPageFormal(),
          '/search_material': (BuildContext context) => new SearchBookPage(),
          '/search_formal': (BuildContext context) => new SearchBookPageNew(),
          '/collection': (BuildContext context) => new CollectionPage(),
          '/stamp_collection_material': (BuildContext context) => new StampCollectionPage(),
          '/stamp_collection_formal': (BuildContext context) => new StampCollectionFormalPage(),
          '/wishlist_page': (BuildContext context) => new WishlistCollectionFormalPage(),
          '/edit_profile': (BuildContext context) => new EditProfilePage(),
          '/friends_page': (BuildContext context) => new FriendListPage(),
          '/loans_page': (BuildContext context) => new LoansPageFormal(),
          '/borrow_requests_page': (BuildContext context) => new BorrowRequestsPageFormal(),
          '/my_pending_requests_page': (BuildContext context) => new MyPendingRequestsPageFormal(),
          '/my_loaned_out_items_page': (BuildContext context) => new MyLoanedOutItemsPage(),
          '/my_notifications_page': (BuildContext context) => new MyNotificationsPage(),
          '/my_chats_list_page': (BuildContext context) => new ChatListPage()
        },
      ),
    );
  }

}

