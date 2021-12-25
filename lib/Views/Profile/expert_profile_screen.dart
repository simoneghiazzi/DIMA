import 'package:flutter/material.dart';
import 'components/expert_profile_body.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';

/// It contains the [ExpertProfileBody] that is used to show the base information
/// of the [expert] and the button for opening a chat a new chat with him/her.
class ExpertProfileScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/expertProfileScreen";
  final Expert expert;

  /// It contains the [ExpertProfileBody] that is used to show the base information
  /// of the [expert] and the button for opening a chat a new chat with him/her.
  const ExpertProfileScreen({Key? key, required this.expert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertProfileBody(expert: expert),
    );
  }
}
