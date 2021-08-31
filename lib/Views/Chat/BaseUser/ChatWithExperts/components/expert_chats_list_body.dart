import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/expert_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/chats_list_constructor.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/components/top_bar.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/map_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertChatsListBody extends StatefulWidget {
  @override
  _ExpertChatsListBodyState createState() => _ExpertChatsListBodyState();
}

class _ExpertChatsListBodyState extends State<ExpertChatsListBody> {
  ChatViewModel chatViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initExpertChats();
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TopBar(text: 'Experts'),
              ChatsListConstructor(
                createUserCallback: createUserCallback,
              ),
            ],
          ),
        ),
        Align(
          alignment:
              Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
          child: FloatingActionButton(
            onPressed: () async {
              routerDelegate.pushPage(name: MapScreen.route);
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.lightBlue[200],
            child: const Icon(
              Icons.add,
              size: 40.0,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    ));
  }

  Expert createUserCallback(DocumentSnapshot doc) {
    Expert user = Expert();
    user.setFromDocument(doc);
    return user;
  }

  void initExpertChats() {
    chatViewModel.conversation.senderUserChat = ExpertChat();
    chatViewModel.conversation.peerUserChat = ActiveChat();
  }
}
