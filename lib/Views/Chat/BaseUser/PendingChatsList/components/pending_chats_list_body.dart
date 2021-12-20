import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/AnonymousChatsList/components/anonymous_chats_list_constructor.dart';
import 'package:sApport/Views/Chat/BaseUser/PendingChatsList/components/pending_chats_list_constructor.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingChatsListBody extends StatefulWidget {
  @override
  _PendingChatsListBodyState createState() => _PendingChatsListBodyState();
}

class _PendingChatsListBodyState extends State<PendingChatsListBody> {
  late ChatViewModel chatViewModel;
  AppRouterDelegate? routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TopBar(back: chatViewModel.resetCurrentChat, text: "Requests"),
          PendingChatsListConstructor(),
        ],
      ),
    );
  }
}
