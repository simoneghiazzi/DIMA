import 'package:auto_size_text/auto_size_text.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  final String text;
  final List<InkWell> buttons;
  final Function back;
  final bool isPortrait;

  TopBar({Key key, @required this.text, this.buttons, this.back, this.isPortrait = false}) : super(key: key);

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
                padding: EdgeInsets.only(right: 20, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    isPortrait
                        ? Container()
                        : IconButton(
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
                    if (buttons != null) ...[...buttons],
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
