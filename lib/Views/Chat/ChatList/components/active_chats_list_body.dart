import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sApport/Views/Chat/components/chat_list_constructor.dart';

/// It contains the [Header] and the [ChatListConstructor] of the active chats of the expert user.
class ActiveChatsListBody extends StatefulWidget {
  /// It contains the [Header] and the [ChatListConstructor] of the active chats of the expert user.
  const ActiveChatsListBody({Key? key}) : super(key: key);

  @override
  _ActiveChatsListBodyState createState() => _ActiveChatsListBodyState();
}

class _ActiveChatsListBodyState extends State<ActiveChatsListBody> {
  // View Models
  late ChatViewModel chatViewModel;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Header(),
          ChatListConstructor(valueNotifier: chatViewModel.activeChats),
        ],
      ),
    );
  }
}
