import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_list_constructor.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Body of the pending chat list page.
///
/// It contains the top bar and the chat list constructor of the pending chats.
class PendingChatsListBody extends StatefulWidget {
  /// Body of the pending chat list page.
  ///
  /// It contains the top bar and the chat list constructor of the pending chats.
  const PendingChatsListBody({Key? key}) : super(key: key);

  @override
  _PendingChatsListBodyState createState() => _PendingChatsListBodyState();
}

class _PendingChatsListBodyState extends State<PendingChatsListBody> {
  // View Models
  late ChatViewModel chatViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

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
          ChatListConstructor(valueNotifier: chatViewModel.pendingChats),
        ],
      ),
    );
  }
}
