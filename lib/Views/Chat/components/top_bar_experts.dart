import 'package:auto_size_text/auto_size_text.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class TopBarExperts extends StatelessWidget {
  final String text;
  final InkWell button;

  TopBarExperts({Key key, @required this.text, this.button}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SafeArea(
          child: SizedBox(
            width: size.width,
            child: Padding(
              padding: EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AutoSizeText(
                    text,
                    style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                    maxLines: 1,
                  ),
                  Spacer(),
                  button ?? Container(),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Color(0xFFD9D9D9),
          height: 1.5,
        ),
      ],
    );
  }
}
