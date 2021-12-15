import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/PendingChatsList/components/pending_chats_list_body.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/constants.dart';
import 'package:split_view/split_view.dart';

class PendingChatsListScreen extends StatefulWidget {
  static const route = '/pendingChatsListScreen';

  @override
  State<PendingChatsListScreen> createState() => _PendingChatsListScreenState();
}

class _PendingChatsListScreenState extends State<PendingChatsListScreen> {
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? PendingChatsListBody()
          : SplitView(
              controller: SplitViewController(weights: [0.35, 0.65]),
              children: [
                PendingChatsListBody(),
                chatViewModel.currentChat == null ? EmptyLandscapeBody() : ChatPageBody(),
              ],
              viewMode: SplitViewMode.Horizontal,
              gripSize: 0.3,
              gripColor: kPrimaryGreyColor,
            ),
    );
  }
}