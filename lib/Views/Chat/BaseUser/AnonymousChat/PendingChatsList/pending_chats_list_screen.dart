import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/components/pending_chats_list_body.dart';
import 'package:flutter/material.dart';

class PendingChatsListScreen extends StatelessWidget {
  final ChatViewModel chatViewModel;

  PendingChatsListScreen({Key key, @required this.chatViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PendingChatsListBody(chatViewModel: chatViewModel),
    );
  }
}
