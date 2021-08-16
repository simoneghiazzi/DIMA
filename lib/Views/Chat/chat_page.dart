import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';

class ChatPage extends StatelessWidget {
  // final ChatViewModel chatsViewModel = ChatViewModel();
  final String peerId;
  final String peerAvatar;
  final LoggedUser loggedUser;

  ChatPage({Key key, @required this.loggedUser, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(loggedUser: loggedUser, peerId: peerId, peerAvatar: peerAvatar),
    );
  }
}
