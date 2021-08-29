import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/AnonymousChat/ActiveChatsList/active_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/BaseUser/ChatWithExperts/expert_chats_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/map_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/create_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dash_card.dart';

class BaseUserGrid extends StatefulWidget {
  final BaseUserViewModel baseUserViewModel;

  BaseUserGrid({Key key, @required this.baseUserViewModel}) : super(key: key);

  @override
  _BaseUserGridState createState() =>
      _BaseUserGridState(baseUserViewModel: baseUserViewModel);
}

class _BaseUserGridState extends State<BaseUserGrid> {
  final BaseUserViewModel baseUserViewModel;
  ChatViewModel chatViewModel;

  _BaseUserGridState({@required this.baseUserViewModel});

  @override
  void initState() {
    super.initState();
    chatViewModel = ChatViewModel(baseUserViewModel.loggedUser);
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ExpertChatsListScreen(
                              chatViewModel: chatViewModel);
                        },
                      ),
                    );
                  },
                ),
                DashCard(
                  imagePath: "assets/icons/anonymous.png",
                  text: "Anonymous chats",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ActiveChatsListScreen(
                              chatViewModel: chatViewModel);
                        },
                      ),
                    );
                  },
                ),
              ]),
              TableRow(children: <Widget>[
                DashCard(
                  imagePath: "assets/icons/map.png",
                  text: "Find an expert",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return MapScreen(
                            chatViewModel: chatViewModel,
                          );
                        },
                      ),
                    );
                  },
                ),
                DashCard(
                  imagePath: "assets/icons/report.png",
                  text: "Anonymous reports",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CreateReportScreen(
                            baseUserViewModel: baseUserViewModel,
                          );
                        },
                      ),
                    );
                  },
                ),
              ])
            ],
          )),
    );
  }
}
