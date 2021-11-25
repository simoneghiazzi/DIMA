import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/expert_chats_list_screen.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Home/components/dash_card.dart';
import 'package:provider/provider.dart';

class BaseUserGrid extends StatefulWidget {
  @override
  _BaseUserGridState createState() => _BaseUserGridState();
}

class _BaseUserGridState extends State<BaseUserGrid> {
  BaseUserViewModel baseUserViewModel;
  ChatViewModel chatViewModel;
  DiaryViewModel diaryViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    diaryViewModel.loggedId = baseUserViewModel.loggedUser.id;
    chatViewModel.conversation.senderUser = baseUserViewModel.loggedUser;
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
                  text: "Experts chats",
                  press: () {
                    routerDelegate.pushPage(name: ExpertChatsListScreen.route);
                  },
                ),
                DashCard(
                  imagePath: "assets/icons/anonymous.png",
                  text: "Anonymous chats",
                  press: () {
                    routerDelegate.pushPage(name: ActiveChatsListScreen.route);
                  },
                ),
              ]),
              TableRow(children: <Widget>[
                DashCard(
                  imagePath: "assets/icons/map.png",
                  text: "Find an expert",
                  press: () {
                    routerDelegate.pushPage(name: MapScreen.route);
                  },
                ),
                DashCard(
                  imagePath: "assets/icons/report.png",
                  text: "Anonymous reports",
                  press: () {
                    routerDelegate.pushPage(name: CreateReportScreen.route);
                  },
                ),
              ])
            ],
          )),
    );
  }
}
