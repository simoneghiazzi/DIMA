import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:flutter/material.dart';

class ChatPageScreen extends StatelessWidget {
  static const route = '/chatPageScreen';

  const ChatPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatPageBody(),
    );
  }
}
