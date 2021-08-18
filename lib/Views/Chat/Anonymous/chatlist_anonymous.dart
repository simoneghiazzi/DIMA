import 'package:dima_colombo_ghiazzi/ViewModel/chatlist_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Anonymous/components/body.dart';

class ChatAnonymous extends StatelessWidget {
  final ChatlistViewModel chatlistViewModel;

  ChatAnonymous({Key key, @required this.chatlistViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(chatlistViewModel: chatlistViewModel),
    );
  }
}
