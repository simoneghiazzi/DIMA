import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/BaseUser/AnonymousChatsList/components/anonymous_chats_list_body.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:sApport/Views/components/empty_portrait_body.dart';
import 'package:sApport/constants.dart';
import 'package:split_view/split_view.dart';

class AnonymousChatsListScreen extends StatefulWidget {
  static const route = '/activeChatsListScreen';

  const AnonymousChatsListScreen({Key key}) : super(key: key);

  @override
  State<AnonymousChatsListScreen> createState() => _AnonymousChatsListScreenState();
}

class _AnonymousChatsListScreenState extends State<AnonymousChatsListScreen> {
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
            ? AnonymousChatsListBody()
            : SplitView(
                controller: SplitViewController(weights: [0.35, 0.65]),
                children: [
                  AnonymousChatsListBody(),
                  chatViewModel.currentChat == null ? EmptyPortraitBody() : ChatPageBody(),
                ],
                viewMode: SplitViewMode.Horizontal,
                gripSize: 0.3,
                gripColor: kPrimaryGreyColor,
              ));
  }
}
