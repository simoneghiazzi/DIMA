import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/BaseUser/PendingChatsList/components/pending_chats_list_body.dart';

class PendingChatsListScreen extends StatelessWidget {
  static const route = '/pendingChatsListScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PendingChatsListBody(),
    );
  }
}
