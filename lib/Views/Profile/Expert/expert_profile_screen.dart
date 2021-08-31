import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/Views/Profile/Expert/components/expert_profile_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpertProfileScreen extends StatelessWidget {
  static const route = '/expertProfileScreen';
  final Expert expert;

  ExpertProfileScreen({Key key, @required this.expert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertProfileBody(
        expert: expert,
      ),
    );
  }
}
