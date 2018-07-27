import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/model/Book.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserCardCompact extends StatelessWidget {
  UserCardCompact({@required this.borrowerName, @required this.book, @required this.ownerEmail, @required this.borrowerEmail});
  final String borrowerName;
  final String ownerEmail;
  final String borrowerEmail;
  final Book book;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_box, color: Colors.blue, size: 30.0,),
            title: Text(borrowerName, style: TextStyle(fontWeight: FontWeight.w400),),
            subtitle: Text('Return request'),
          ),
          Divider(),
          SizedBox(height: 30.0,),
          Hero(child: Image.network(book.url), tag: book.id,),
          SizedBox(height: 30.0,),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(child: Text('Verify return'), color: Colors.orangeAccent, onPressed: () {
                  DocumentReference ref = Firestore.instance.collection('loans').document(borrowerEmail + book.id + ownerEmail);
                  DocumentReference ref2 = Firestore.instance.collection('return requests').document(borrowerEmail + book.id + ownerEmail);
                  Firestore.instance.runTransaction((Transaction txn) async {
                    await ref.delete();
                    await ref2.delete();
                  });
                  Fluttertoast.showToast(msg: 'Verified Return of book!', toastLength: Toast.LENGTH_SHORT);
                },),
              ),
            ],
          ),
          SizedBox(height: 15.0,),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(child: Text('Open Dispute'), color: Colors.blueGrey, onPressed: () {
                  //TODO open dispute
                  Fluttertoast.showToast(msg: borrowerName + ' reported for further investigation.', toastLength: Toast.LENGTH_LONG);
                },),
              ),
            ],
          )
        ],
      ),
    );
  }

}