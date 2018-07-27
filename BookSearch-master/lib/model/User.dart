import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  String name, email, contact, imageURL;

  User({
    @required this.name,
    @required this.email,
    this.contact,
    this.imageURL
  });

  User.fromMap(Map <String, dynamic> map) : this (
      name: map['name'],
      email: map['email'],
      contact: map['contact']
  );

  User.fromJson(Map <String, dynamic> json)
      : name = json['name'],
        contact = json['contact'],
        email = json['email'];

}