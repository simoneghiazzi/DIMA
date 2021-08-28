import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'compoents/profile_body.dart';

class ProfileExpertScreen extends StatelessWidget {
  final ChatViewModel chatViewModel;
  final Expert expert;

  ProfileExpertScreen(
      {Key key, @required this.chatViewModel, @required this.expert})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileBody(
        chatViewModel: chatViewModel,
        expert: expert,
      ),
    );
  }
}
