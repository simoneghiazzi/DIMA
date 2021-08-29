import 'package:auto_size_text/auto_size_text.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String text;
  final CircleAvatar circleAvatar;
  final InkWell button;

  TopBar({Key key, @required this.text, this.circleAvatar, this.button})
      : super(key: key);

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
              padding: EdgeInsets.only(right: 20, left: 10, top: 12, bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(
                      Icons.arrow_back,
                      color: kPrimaryColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  circleAvatar ?? Container(),
                  circleAvatar != null
                      ? SizedBox(
                          width: size.width * 0.04,
                        )
                      : Container(),
                  AutoSizeText(
                    text,
                    style: TextStyle(
                        fontSize: 25.0,
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
