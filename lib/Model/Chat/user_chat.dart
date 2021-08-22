import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String name;
  String photoUrl;

  UserChat({this.id, this.name, this.photoUrl});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String uid = "";
    String name = "";
    String photoUrl = ""; 
    try {
      uid = doc.id;
    } catch (e) {}    
    try {
      name = doc.get('name');
    } catch (e) {}
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    return UserChat(
      id: uid,
      name: name,
      photoUrl: photoUrl,
    );
  }

  factory UserChat.fromMap(Map map) {
    String uid = "";
    String name = "";
    String photoUrl = ""; 
    try {
      uid = map['uid'];
    } catch (e) {}    
    try {
      name = map['name'];
    } catch (e) {}
    try {
      photoUrl = map['photoUrl'];
    } catch (e) {}
    return UserChat(
      id: uid,
      name: name,
      photoUrl: photoUrl,
    );
  }
}