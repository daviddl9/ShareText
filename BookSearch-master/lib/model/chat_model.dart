import 'package:test_app/model/User.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final User sender;
  final User receiver;
  final String message;
  final String time;


  ChatModel({this.sender, this.receiver, this.message, this.time});

  ChatModel.fromSnapshot(DataSnapshot snapshot)
      : receiver = User(email: snapshot.value['receiverEmail'], name: snapshot.value['receiverName']),
        message = snapshot.value['text'],
        sender = User(email: snapshot.value['email'], name: snapshot.value['senderName']),
        time = snapshot.value['time'];

  toJson() {
    return {
      'email': sender.email,
      'receiverEmail': receiver.email,
      'receiverName': receiver.name,
      'senderName': sender.name,
      'text': message,
      'time': time
    };
  }


}

List<ChatModel> dummyData = [
  new ChatModel(
      sender: User(name: 'Aaron Ong', email: 'ong.aaron96@gmail.com'),
      message: "Hey David!",
      time: "15:30",
  ),
  new ChatModel(
      sender: User(name: 'Salomone', email: 'darsalomone@gmail.com'),
      message: "Cool!",
      time: "17:30",),
  new ChatModel(
      sender: User(name: 'Timothy Aananth Moses', email: 'timmymoses17@gmail.com'),
      message: "Wassup !",
      time: "5:00",
  ),
  new ChatModel(
    sender: User(name: 'David Livingston', email: 'ddl.tdh@gmail.com'),
    message: 'Yo!',
    time: '18:00'
  )
];