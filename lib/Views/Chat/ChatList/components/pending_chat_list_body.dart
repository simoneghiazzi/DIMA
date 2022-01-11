import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_constructor.dart';

/// It contains the [TopBar] and the [ChatListConstructor] of the pending chats.
class PendingChatListBody extends StatefulWidget implements ChatListBody {
  /// The type of chat that it contains
  Type get chatType => PendingChat;

  /// It contains the [TopBar] and the [ChatListConstructor] of the pending chats.
  const PendingChatListBody({Key? key}) : super(key: key);

  @override
  _PendingChatListBodyState createState() => _PendingChatListBodyState();
}

class _PendingChatListBodyState extends State<PendingChatListBody> {
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
          TopBar(onBack: chatViewModel.resetCurrentChat, text: "Requests"),
          ChatListConstructor(valueNotifier: chatViewModel.pendingChats),
        ],
      ),
    );
  }
}
