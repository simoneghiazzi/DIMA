import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Expert/expert_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chats_list_constructor.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertHomePageBody extends StatefulWidget {
  @override
  _ExpertHomePageBodyState createState() => _ExpertHomePageBodyState();
}

class _ExpertHomePageBodyState extends State<ExpertHomePageBody> {
  bool newPendingChats;
  ChatViewModel chatViewModel;
  ExpertViewModel expertViewModel;
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    super.initState();
    expertViewModel = Provider.of<ExpertViewModel>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel.setNotification(expertViewModel.loggedUser);
    chatViewModel.conversation.senderUser = expertViewModel.loggedUser;
    initActiveChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Header(),
        ChatsListConstructor(
          createUserCallback: createUserCallback,
          peerCollection: Collection.BASE_USERS,
        ),
      ],
    ));
  }

  BaseUser createUserCallback(DocumentSnapshot doc) {
    BaseUser user = BaseUser();
    user.setFromDocument(doc);
    return user;
  }

  void initActiveChats() {
    chatViewModel.conversation.senderUserChat = ActiveChat();
    chatViewModel.conversation.peerUserChat = ExpertChat();
  }
}
