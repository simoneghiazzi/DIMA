import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/components/active_chats_list_body.dart';
import 'package:flutter/material.dart';

class ActiveChatsListScreen extends StatelessWidget {
  final ChatViewModel chatViewModel;

  ActiveChatsListScreen({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActiveChatsListBody(chatViewModel: chatViewModel),
    );
  }
}