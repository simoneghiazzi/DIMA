import 'package:provider/provider.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/components/active_chats_list_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/components/empty_page_portrait.dart';
import 'package:sApport/constants.dart';
import 'package:split_view/split_view.dart';

class ActiveChatsListScreen extends StatefulWidget {
  static const route = '/activeChatsListScreen';

  @override
  State<ActiveChatsListScreen> createState() => _ActiveChatsListScreenState();
}

class _ActiveChatsListScreenState extends State<ActiveChatsListScreen> {
  ChatViewModel chatViewModel;
  bool isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    //StreamSubscription<bool> subscriber = subscribeToViewModel();

    var isPortrait = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isPortrait
          ? SplitView(
              controller: SplitViewController(weights: [0.3, 0.7]),
              children: [
                ActiveChatsListBody(),
                StreamBuilder(
                    stream: chatViewModel.isChatOpen,
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return ChatPageScreen();
                      }
                      return EmptyPagePortrait();
                    })
                //isChatOpen ? ChatPageScreen() : EmptyPagePortrait(),
              ],
              viewMode: SplitViewMode.Horizontal,
              gripSize: 1.0,
              gripColor: kPrimaryColor,
            )
          : ActiveChatsListBody(),
    );
  }

  // StreamSubscription<bool> subscribeToViewModel() {
  //   return chatViewModel.isChatOpen.listen((isChatBeenOpened) {
  //     if (isChatBeenOpened) {
  //       setState(() {
  //         isChatOpen = true;
  //       });
  //     }
  //   });
  // }
}
