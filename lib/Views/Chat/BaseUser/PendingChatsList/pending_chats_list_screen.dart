import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/PendingChatsList/components/pending_chats_list_body.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';

class PendingChatsListScreen extends StatefulWidget {
  static const route = '/pendingChatsListScreen';

  @override
  State<PendingChatsListScreen> createState() => _PendingChatsListScreenState();
}

class _PendingChatsListScreenState extends State<PendingChatsListScreen> {
  late ChatViewModel chatViewModel;
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? PendingChatsListBody()
          : VerticalSplitView(
              left: PendingChatsListBody(),
              right: ValueListenableBuilder(
                valueListenable: chatViewModel.currentChat,
                builder: (context, Chat? chat, child) {
                  if (chat != null) {
                    return ChatPageBody(key: ValueKey(chat.peerUser!.id));
                  } else {
                    return EmptyLandscapeBody();
                  }
                },
              ),
              ratio: 0.35,
            ),
    );
  }
}
