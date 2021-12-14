import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/expert_chats_list_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/components/chat_accept_deny.dart';
import 'package:sApport/Views/Chat/components/chat_text_input.dart';
import 'package:sApport/Views/Chat/components/messages_list_constructor.dart';
import 'package:sApport/Views/Chat/components/top_bar_chats.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPageBody extends StatefulWidget {
  // //To check which is the orientation when the page is first opened
  // bool startOrientation;

  @override
  _ChatPageBodyState createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody> with WidgetsBindingObserver {
  UserViewModel userViewModel;
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel.updateChattingWith();
    BackButtonInterceptor.add(backButtonInterceptor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //detectChangeOrientation();

    return Column(
      children: <Widget>[
        chatViewModel.chat.peerUser is BaseUser
            ? TopBarChats(
                back: backFromChat,
                isPortrait: MediaQuery.of(context).orientation == Orientation.landscape,
                circleAvatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                text: chatViewModel.chat.peerUser.data["name"].toString() +
                    (userViewModel.loggedUser is Expert ? " " + chatViewModel.chat.peerUser.data["surname"].toString() : ""),
              )
            : TopBarChats(
                isPortrait: MediaQuery.of(context).orientation == Orientation.landscape,
                networkAvatar: NetworkAvatar(
                  img: chatViewModel.chat.peerUser.data["profilePhoto"],
                  radius: 20.0,
                ),
                text: chatViewModel.chat.peerUser.data["name"].toString() + " " + chatViewModel.chat.peerUser.data["surname"].toString(),
              ),
        // List of messages
        MessagesListConstructor(),
        // Input content
        chatViewModel.chat is PendingChat ? ChatAcceptDenyInput() : ChatTextInput(),
      ],
    );
  }

  void backFromChat() {
    if (chatViewModel.chat is Request) {
      chatViewModel.setAnonymousChat();
    }
    chatViewModel.resetChattingWith();
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backFromChat();
    routerDelegate.pop();
    return true;
  }

  // Future<void> detectChangeOrientation() async {
  //   AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
  //   if (widget.startOrientation != (MediaQuery.of(context).orientation == Orientation.landscape)) {
  //     widget.startOrientation = true;
  //     await Future(() async {
  //       if (chatViewModel.conversation.peerUser is Expert) {
  //         routerDelegate.replaceAllButNumber(2, [
  //           RouteSettings(
  //               name: ExpertChatsListScreen.route,
  //               arguments: ChatPageScreen(
  //                 startOrientation: true,
  //               ))
  //         ]);
  //       } else {
  //         routerDelegate.replaceAllButNumber(2, [
  //           RouteSettings(
  //               name: ActiveChatsListScreen.route,
  //               arguments: ChatPageScreen(
  //                 startOrientation: true,
  //               ))
  //         ]);
  //       }
  //     });
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      chatViewModel.updateChattingWith();
    } else {
      chatViewModel.resetChattingWith();
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
