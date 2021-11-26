import 'package:sApport/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/components/active_chats_list_body.dart';
import 'package:flutter/material.dart';

class ActiveChatsListScreen extends StatelessWidget {
  static const route = '/activeChatsListScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActiveChatsListBody(),
    );
  }
}
