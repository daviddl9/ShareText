import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/abstract/search_user_page_abstract.dart';
import 'package:test_app/pages/formal/search_user_list_formal.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'dart:math';

import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/book_card_compact.dart';

class SearchUserPageFormal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchUserPageFormalState();

}

String name;
final TextEditingController textController = TextEditingController();

class _SearchUserPageFormalState extends AbstractSearchUserState<SearchUserPageFormal> {

    @override
    Widget build(BuildContext context) {
      const textStyle = const TextStyle(
          fontSize: 35.0,
          fontFamily: 'Butler',
          fontWeight: FontWeight.w400
      );
      return new Scaffold(
        key: userKey,
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              forceElevated: true,
              backgroundColor: Colors.white,
              elevation: 1.0,
              iconTheme: new IconThemeData(color: Colors.black),
            ),
            new SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: new SliverToBoxAdapter(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new SizedBox(height: 8.0,),
                    new Text("Search Users", style: textStyle,),
                    new SizedBox(height: 16.0),
                    new Card(
                        elevation: 4.0,
                        child: new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new TextField(
                            controller: textController,
                            decoration: new InputDecoration(
                                hintText: "Search users here.",
                                prefixIcon: new Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Icon(Icons.search),
                                ),
                                border: InputBorder.none
                            ),
                            onChanged: (string) => (subject.add(string)),
                          ),
                        )
                    ),
                    new SizedBox(height: 12.0,),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: new RaisedButton(onPressed: () {
                                  // Navigate away from the page with the required text.
                                  Navigator.of(context).push(FadeRoute(
                                    builder: (context) => SearchUserListPageFormal(textController.text),
                                    settings: RouteSettings(
                                      name: '/user_search_list_page_formal',
                                      isInitialRoute: false
                                    )
                                  )
                                  );
                                }, child: Text('Search'), splashColor: Colors.blueGrey,),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
            //TODO find out why this doesn't work. Does isLoading get changed at all?
          ],
        ),
      );
    }
}
