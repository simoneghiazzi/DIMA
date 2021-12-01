import 'package:auto_size_text/auto_size_text.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  final String text;
  final InkWell button;
  final Function back;

  TopBar({Key key, @required this.text, this.button, this.back}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Container(
      color: kPrimaryColor,
      height: size.height / 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SafeArea(
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: EdgeInsets.only(right: 20, left: 10, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: back ??
                          () {
                            routerDelegate.pop();
                          },
                    ),
                    AutoSizeText(
                      text,
                      style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                    ),
                    Spacer(),
                    button ?? Container(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
