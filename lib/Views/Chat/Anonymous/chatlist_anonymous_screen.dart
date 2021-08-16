import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Anonymous/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';

class ChatAnonymous extends StatelessWidget {
  final ChatViewModel chatsViewModel = ChatViewModel();
  final LoggedUser loggedUser;

  ChatAnonymous({Key key, @required this.loggedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(loggedUser: loggedUser),
    );
  }
}
