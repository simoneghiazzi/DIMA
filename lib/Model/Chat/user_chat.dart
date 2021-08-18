import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String name;

  UserChat({this.id, this.photoUrl, this.name});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String name = "";
    String uid = "";
    try {
      uid = doc.get('uid');
    } catch (e) {}
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    try {
      name = doc.get('name');
    } catch (e) {}
    return UserChat(
      id: uid,
      photoUrl: photoUrl,
      name: name,
    );
  }
}