import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/ChatsList/Anonymous/chat_anonymous_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/ChatsList/Experts/chat_experts_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 90),
        child: GridView.count(
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
                      return ChatExperts();
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
                      return ChatAnonymous();
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
        ),
      ),
    );
  }
}
