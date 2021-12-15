import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/components/expert_chats_list_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/constants.dart';
import 'package:split_view/split_view.dart';

class ExpertChatsListScreen extends StatefulWidget {
  static const route = '/expertChatsListScreen';
  final Widget chatPage;

  const ExpertChatsListScreen({Key key, this.chatPage}) : super(key: key);

  @override
  State<ExpertChatsListScreen> createState() => _ExpertChatsListScreenState();
}

class _ExpertChatsListScreenState extends State<ExpertChatsListScreen> {
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
          ? ExpertChatsListBody()
          : SplitView(
              controller: SplitViewController(weights: [0.35, 0.65]),
              children: [
                ExpertChatsListBody(),
                chatViewModel.currentChat == null ? EmptyLandscapeBody() : ChatPageBody(),
              ],
              viewMode: SplitViewMode.Horizontal,
              gripSize: 0.3,
              gripColor: kPrimaryGreyColor,
            ),
    );
  }
}
