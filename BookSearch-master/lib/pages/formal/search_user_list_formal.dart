import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/pages/formal/user_profile_page_formal.dart';
import 'package:test_app/utils/utils.dart';

class SearchUserListPageFormal extends StatelessWidget {
  final String text;
  SearchUserListPageFormal(this.text);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Users: $text'),),
      body: StreamBuilder(
          stream: Firestore.instance.collection('users').where('name', isGreaterThanOrEqualTo: text).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(),);
            }
            return ListView.builder(
                itemExtent: 55.0,
                padding: EdgeInsets.only(top: 10.0),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]));
          }
      ),
    );
  }

  _buildListItem(BuildContext context, document) {
    return ListTile(
        key: ValueKey(document.documentID),
        title: Container(
//          decoration: BoxDecoration(
//              border: Border.all(color: Color(0x80000000)),
//              borderRadius: BorderRadius.circular(5.0)
//          ),
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(document['name']),
              ),
              CircleAvatar(
                backgroundColor: Colors.amber,
                child: Text(document['name'][0]),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
              FadeRoute(
                  builder: (context) =>
                      UserDetailsPageFormal(User(name: document['name'], email: document['email'], contact: document['contact'])),
                  settings: RouteSettings(
                      name: '/user_details_page',
                      isInitialRoute: false
                  )
              )
          );
        }
    );
  }

}