import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Profile/Expert/components/expert_profile_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpertProfileScreen extends StatelessWidget {
  final ChatViewModel chatViewModel;
  final Expert expert;

  ExpertProfileScreen(
      {Key key, @required this.chatViewModel, @required this.expert})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertProfileBody(
        chatViewModel: chatViewModel,
        expert: expert,
      ),
    );
  }
}
