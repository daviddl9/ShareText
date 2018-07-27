import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test_app/model/User.dart';
import 'package:test_app/model/chat_model.dart';
import 'package:test_app/pages/formal/chat_screen_formal.dart';
import 'package:test_app/utils/utils.dart';

class ChatListPage extends StatefulWidget {
  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Chats'),),
      body: new ListView.builder(
        itemCount: dummyData.length,
        itemBuilder: (context, i) => new Column(
          children: <Widget>[
            new Divider(
              height: 10.0,
            ),
            new ListTile(
              leading: new Icon(Icons.account_circle, size: 55.0, color: Colors.blueGrey,),
              title: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    dummyData[i].sender.name,
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                  new Text(
                    dummyData[i].time,
                    style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ],
              ),
              subtitle: new Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: new Text(
                  dummyData[i].message,
                  style: new TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(new FadeRoute(
                  builder: (BuildContext context) => new ChatScreen(dummyData[i].sender),
                  settings: new RouteSettings(name: '/chat_screen_page_user_formal', isInitialRoute: false),
                ));
              },
            )
          ],
        ),
      ),
    );
  }

}