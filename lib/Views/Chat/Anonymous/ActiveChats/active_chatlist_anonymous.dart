import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Anonymous/ActiveChats/components/body.dart';

class ActiveChatAnonymous extends StatelessWidget {
  final ChatViewModel chatViewModel;

  ActiveChatAnonymous({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatViewModel: chatViewModel),
    );
  }
}
