import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Anonymous/components/body.dart';

class ChatAnonymous extends StatelessWidget {
  final ChatViewModel chatViewModel;

  ChatAnonymous({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatViewModel: chatViewModel),
    );
  }
}
