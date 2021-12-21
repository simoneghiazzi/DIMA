import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveChatsListBody extends StatefulWidget {
  const ActiveChatsListBody({Key? key}) : super(key: key);

  @override
  _ActiveChatsListBodyState createState() => _ActiveChatsListBodyState();
}

class _ActiveChatsListBodyState extends State<ActiveChatsListBody> {
  ChatViewModel? chatViewModel;
  late UserViewModel userViewModel;
  late AuthViewModel authViewModel;
  AppRouterDelegate? routerDelegate;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel.setNotification(userViewModel.loggedUser!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Header(),
        //ChatsListConstructor(createChatCallback: (String id) => ActiveChat.fromId(id)),
      ],
    ));
  }
}
