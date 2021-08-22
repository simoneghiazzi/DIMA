import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';

class ChatPage extends StatelessWidget {
  final ChatViewModel chatViewModel;
  final bool newUser;

  ChatPage({Key key, @required this.chatViewModel, @required this.newUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatViewModel: chatViewModel, newUser: newUser,),
    );
  }
}
