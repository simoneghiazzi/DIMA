import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chats_list_constructor.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingChatsListBody extends StatefulWidget {
  @override
  _PendingChatsListBodyState createState() => _PendingChatsListBodyState();
}

class _PendingChatsListBodyState extends State<PendingChatsListBody> {
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    initPendingChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TopBar(text: 'Requests'),
          ChatsListConstructor(
            createUserCallback: createUserCallback,
            peerCollection: Collection.BASE_USERS,
          ),
        ],
      ),
    );
  }

  BaseUser createUserCallback(DocumentSnapshot doc) {
    BaseUser user = BaseUser();
    user.setFromDocument(doc);
    return user;
  }

  void initPendingChats() {
    chatViewModel.conversation.senderUserChat = PendingChat();
    chatViewModel.conversation.peerUserChat = Request();
  }
}
