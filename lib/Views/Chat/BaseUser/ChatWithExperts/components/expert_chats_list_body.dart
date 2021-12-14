import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/components/chats_list_constructor.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/constants.dart';
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
    if (chatViewModel.chat is! ExpertChat) {
      chatViewModel.setExpertChat();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(text: 'Experts'),
            ChatsListConstructor(createUserCallback: createUserCallback),
          ],
        ),
        Align(
          alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
          child: FloatingActionButton(
            onPressed: () async {
              routerDelegate.pushPage(name: MapScreen.route);
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: kPrimaryColor,
            child: const Icon(
              Icons.add,
              size: 40.0,
              color: Colors.white,
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
}
