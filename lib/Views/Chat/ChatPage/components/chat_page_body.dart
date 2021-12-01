import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chat_accept_deny.dart';
import 'package:sApport/Views/Chat/components/chat_text_input.dart';
import 'package:sApport/Views/Chat/components/messages_list_constructor.dart';
import 'package:sApport/Views/Chat/components/top_bar_chats.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPageBody extends StatefulWidget {
  @override
  _ChatPageBodyState createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody> with WidgetsBindingObserver {
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;
  User peerUser, senderUser;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    peerUser = chatViewModel.conversation.peerUser;
    senderUser = chatViewModel.conversation.senderUser;
    chatViewModel.updateChattingWith();
    BackButtonInterceptor.add(backButtonInterceptor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        peerUser.collection == Collection.EXPERTS
            ? TopBarChats(
                networkAvatar: NetworkAvatar(
                  img: peerUser.getData()['profilePhoto'],
                  radius: 20.0,
                ),
                text: peerUser.getData()['name'] + " " + peerUser.getData()['surname'],
              )
            : TopBarChats(
                circleAvatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                text: peerUser.getData()['name'] + (senderUser.collection == Collection.EXPERTS ? " " + peerUser.getData()['surname'] : ""),
              ), // List of messages
        MessagesListConstructor(),
        // Input content
        chatViewModel.conversation.senderUserChat.runtimeType == PendingChat ? ChatAcceptDenyInput() : ChatTextInput(),
      ],
    );
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    chatViewModel.resetChattingWith();
    routerDelegate.pop();
    return true;
  }

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
