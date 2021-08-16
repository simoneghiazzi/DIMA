import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;

  UserChat({this.id, this.photoUrl, this.nickname});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    String uid = "";
    try {
      uid = doc.get('uid');
    } catch (e) {}
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    try {
      nickname = doc.get('name');
    } catch (e) {}
    return UserChat(
      id: uid,
      photoUrl: photoUrl,
      nickname: nickname,
    );
  }
}