import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/components/expert_chats_list_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/components/empty_page_portrait.dart';
import 'package:split_view/split_view.dart';

import '../../../../constants.dart';

class ExpertChatsListScreen extends StatefulWidget {
  static const route = '/expertChatsListScreen';
  final Widget chatPage;

  const ExpertChatsListScreen({Key key, this.chatPage}) : super(key: key);

  @override
  State<ExpertChatsListScreen> createState() => _ExpertChatsListScreenState();
}

class _ExpertChatsListScreenState extends State<ExpertChatsListScreen> {
  ChatViewModel chatViewModel;
  bool isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    //detectChangeOrientation();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: 
      // MediaQuery.of(context).orientation == Orientation.landscape
      //     ? SplitView(
      //         controller: SplitViewController(weights: [0.3, 0.7]),
      //         children: [
      //           ExpertChatsListBody(),
      //           widget.chatPage == null
      //               ? StreamBuilder(
      //                   stream: chatViewModel.isChatOpen,
      //                   builder: (context, snapshot) {
      //                     if (snapshot.data == true) {
      //                       isChatOpen = true;
      //                       return ChatPageScreen(
      //                         startOrientation: MediaQuery.of(context).orientation == Orientation.landscape,
      //                       );
      //                     }
      //                     return EmptyPagePortrait();
      //                   })
      //               : widget.chatPage,
      //         ],
      //         viewMode: SplitViewMode.Horizontal,
      //         gripSize: 1.0,
      //         gripColor: kPrimaryColor,
      //       )
      //     : 
          ExpertChatsListBody(),
    );
  }

  // Future<void> detectChangeOrientation() async {
  //   AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
  //   await Future(() async {
  //     if ((MediaQuery.of(context).orientation == Orientation.portrait) && isChatOpen) {
  //       routerDelegate.pushPage(name: ChatPageScreen.route);
  //     }
  //   });
  // }
}
