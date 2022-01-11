import 'package:flutter/material.dart';
import 'components/expert_profile_body.dart';

/// It contains the [ExpertProfileBody] that is used to show the base information
/// of the [expert] and the button for opening a chat a new chat with him/her.
class ExpertProfileScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/expertProfileScreen";

  /// It contains the [ExpertProfileBody] that is used to show the base information
  /// of the [expert] and the button for opening a chat a new chat with him/her.
  const ExpertProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ExpertProfileBody());
  }
}
