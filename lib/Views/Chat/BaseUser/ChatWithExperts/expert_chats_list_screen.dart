import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/ChatWithExperts/components/expert_chats_list_body.dart';
import 'package:flutter/material.dart';

class ExpertChatsListScreen extends StatelessWidget {
  final ChatViewModel chatViewModel;

  ExpertChatsListScreen({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertChatsListBody(chatViewModel: chatViewModel),
    );
  }
}
