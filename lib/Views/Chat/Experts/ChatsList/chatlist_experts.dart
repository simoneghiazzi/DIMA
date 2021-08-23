import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Experts/ChatsList/components/body.dart';

class ChatExperts extends StatelessWidget {

  final ChatViewModel chatViewModel;

  ChatExperts({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatViewModel: chatViewModel),
    );
  }
}
