import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;

  UserChat({this.id, this.photoUrl, this.nickname});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    try {
      nickname = doc.get('nickname');
    } catch (e) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
    );
  }
}