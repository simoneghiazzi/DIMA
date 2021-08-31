import 'package:flutter/material.dart';

import 'components/active_chats_experts_body.dart';

class ActiveChatsExpertsScreen extends StatelessWidget {
  static const route = '/activeChatsExpertScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActiveChatsExpertsBody(),
    );
  }
}
