import 'package:flutter/material.dart';
import 'components/expert_profile_body.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';

class ExpertProfileScreen extends StatelessWidget {
  static const route = '/expertProfileScreen';
  final Expert? expert;

  ExpertProfileScreen({Key? key, required this.expert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertProfileBody(
        expert: expert,
      ),
    );
  }
}
