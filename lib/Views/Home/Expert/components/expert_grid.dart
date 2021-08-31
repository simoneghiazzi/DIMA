import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dash_card.dart';
import 'package:provider/provider.dart';

class ExpertGrid extends StatefulWidget {
  @override
  _ExpertGridState createState() => _ExpertGridState();
}

class _ExpertGridState extends State<ExpertGrid> {
  ChatViewModel chatViewModel;
  ExpertViewModel expertViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    expertViewModel = Provider.of<ExpertViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    chatViewModel.conversation.senderUser = expertViewModel.loggedUser;
    initExpertChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            defaultColumnWidth: FlexColumnWidth(15.0),
            children: <TableRow>[
              TableRow(children: <Widget>[
                DashCard(
                  imagePath: "assets/icons/psychologist.png",
                  text: "Chats",
                  press: () {},
                ),
              ]),
            ],
          )),
    );
  }

  void initExpertChats() {
    chatViewModel.conversation.senderUserChat = ActiveChat();
    chatViewModel.conversation.peerUserChat = ActiveChat();
  }
}
