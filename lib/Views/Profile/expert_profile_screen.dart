import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:flutter/material.dart';
import 'components/expert_profile_body.dart';

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
