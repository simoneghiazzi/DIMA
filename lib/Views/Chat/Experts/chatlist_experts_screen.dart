import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Experts/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';

class ChatExperts extends StatelessWidget {
  final ChatViewModel chatsViewModel = ChatViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatsViewModel: chatsViewModel),
    );
  }
}
