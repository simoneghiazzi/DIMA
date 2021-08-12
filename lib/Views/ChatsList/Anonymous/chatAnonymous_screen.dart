import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/ChatsList/Anonymous/components/body.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chatsViewModel.dart';

class ChatsAnonymous extends StatelessWidget {
  final ChatsViewModel chatsViewModel = ChatsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatsViewModel: chatsViewModel),
    );
  }
}
