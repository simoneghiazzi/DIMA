import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_constructor.dart';

/// It contains the [Header] and the [ChatListConstructor] of the active chats of the expert user.
class ActiveChatListBody extends StatefulWidget implements ChatListBody {
  /// The type of chat that it contains
  Type get chatType => ActiveChat;

  /// It contains the [Header] and the [ChatListConstructor] of the active chats of the expert user.
  const ActiveChatListBody({Key? key}) : super(key: key);

  @override
  _ActiveChatListBodyState createState() => _ActiveChatListBodyState();
}

class _ActiveChatListBodyState extends State<ActiveChatListBody> {
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
