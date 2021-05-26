import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chats/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ChatsViewModel.dart';

class ChatsScreen extends StatelessWidget {
  final ChatsViewModel chatsViewModel = ChatsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatsViewModel: chatsViewModel),
    );
  }
}
