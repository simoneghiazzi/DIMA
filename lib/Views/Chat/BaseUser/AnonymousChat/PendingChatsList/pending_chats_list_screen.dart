import 'package:sApport/Views/Chat/BaseUser/AnonymousChat/PendingChatsList/components/pending_chats_list_body.dart';
import 'package:flutter/material.dart';

class PendingChatsListScreen extends StatelessWidget {
  static const route = '/pendingChatsListScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PendingChatsListBody(),
    );
  }
}
