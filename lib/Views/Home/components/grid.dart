import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dashCard.dart';

class Grid extends StatelessWidget {
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
              press: () {
                print("hola");
              },
            ),
            DashCard(
              imagePath: "assets/icons/anonymous.png",
              press: () {
                print("hola");
              },
            ),
            DashCard(
              imagePath: "assets/icons/map.png",
              press: () {
                print("hola");
              },
            ),
            DashCard(
              imagePath: "assets/icons/report.png",
              press: () {
                print("hola");
              },
            ),
          ],
        ),
      ),
    );
  }
}
