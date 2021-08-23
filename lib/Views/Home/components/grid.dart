import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Anonymous/ActiveChats/active_chatlist_anonymous.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/Experts/chatlist_experts.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/map_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dash_card.dart';

class Grid extends StatefulWidget {
  final AuthViewModel authViewModel;

  Grid({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  ChatViewModel chatViewModel;

  @override
  void initState() {
    super.initState();
    chatViewModel = ChatViewModel(widget.authViewModel.loggedUser.uid);
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
                          return ChatExperts(chatViewModel: chatViewModel);
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
                          return ActiveChatAnonymous(
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
                          return MapScreen();
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
                          return ReportScreen(
                            authViewModel: widget.authViewModel,
                          );
                        },
                      ),
                    );
                  },
                ),
              ])
            ],
          )
          /*GridView.count(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 2,
          childAspectRatio: .90,
          children: <Widget>[
            DashCard(
              imagePath: "assets/icons/psychologist.png",
              text: "Experts chats",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ChatExperts(chatViewModel: chatViewModel);
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
                      return ActiveChatAnonymous(chatViewModel: chatViewModel);
                    },
                  ),
                );
              },
            ),
            DashCard(
              imagePath: "assets/icons/map.png",
              text: "Map",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MapScreen();
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
                      return ReportScreen(
                        authViewModel: widget.authViewModel,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),*/
          ),
    );
  }
}
