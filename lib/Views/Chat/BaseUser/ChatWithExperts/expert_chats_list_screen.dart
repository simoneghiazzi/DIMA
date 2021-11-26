import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/components/expert_chats_list_body.dart';
import 'package:flutter/material.dart';

class ExpertChatsListScreen extends StatelessWidget {
  static const route = '/expertChatsListScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertChatsListBody(),
    );
  }
}
