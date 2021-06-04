import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:dima_colombo_ghiazzi/Views/Chats/chatsList_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Map/map_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dashCard.dart';

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
                      return ChatsScreen();
                    },
                  ),
                );
              },
            ),
            DashCard(
              imagePath: "assets/icons/anonymous.png",
              text: "Anonymous chats",
              press: () {
                print("hola");
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
              text: "Anonymous report",
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
