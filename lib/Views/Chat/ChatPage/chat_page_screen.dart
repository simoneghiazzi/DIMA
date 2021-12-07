import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:flutter/material.dart';

class ChatPageScreen extends StatelessWidget {
  //To check which is the orientation when the page is first opened
  final bool startOrientation;

  static const route = '/chatPageScreen';

  const ChatPageScreen({Key key, this.startOrientation = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatPageBody(
        startOrientation: startOrientation,
      ),
    );
  }
}
