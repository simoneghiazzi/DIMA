import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:flutter/material.dart';

import 'components/active_chats_experts_body.dart';

class ActiveChatsExpertsScreen extends StatelessWidget {
  final AuthViewModel authViewModel;
  final ExpertViewModel expertViewModel;

  ActiveChatsExpertsScreen(
      {Key key, @required this.authViewModel, @required this.expertViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActiveChatsExpertsBody(
        authViewModel: authViewModel,
        userViewModel: expertViewModel,
      ),
    );
  }
}
