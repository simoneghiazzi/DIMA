import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:flutter/material.dart';

class ChatPageScreen extends StatelessWidget {
  static const route = '/chatPageScreen';
  final bool isExpert;

  ChatPageScreen({Key key, this.isExpert = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatPageBody(),
    );
  }
}
