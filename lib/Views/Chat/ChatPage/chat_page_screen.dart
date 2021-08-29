import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';

class ChatPageScreen extends StatelessWidget {
  final ChatViewModel chatViewModel;

  ChatPageScreen({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatPageBody(
          chatViewModel: chatViewModel),
    );
  }
}
