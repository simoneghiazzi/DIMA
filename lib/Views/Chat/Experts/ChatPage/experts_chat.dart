import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Experts/ChatPage/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';

class ExpertsChat extends StatelessWidget {
  final ChatViewModel chatViewModel;

  ExpertsChat({Key key, @required this.chatViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatViewModel: chatViewModel),
    );
  }
}
