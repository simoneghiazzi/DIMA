import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';

class ChatAcceptDenyInput extends StatefulWidget {
  @override
  _ChatAcceptDenyInputState createState() => _ChatAcceptDenyInputState();
}

class _ChatAcceptDenyInputState extends State<ChatAcceptDenyInput> {
  @override
  Widget build(BuildContext context) {
    var chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Divider(
          color: kPrimaryLightColor,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 25, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.25,
                    minHeight: size.height / 20,
                  ),
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.green,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Accept",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  chatViewModel.acceptPendingChat();
                  if (MediaQuery.of(context).orientation == Orientation.portrait) {
                    routerDelegate.replaceAllButNumber(3, routeSettingsList: [
                      RouteSettings(name: ChatPageScreen.route),
                    ]);
                  } else {
                    routerDelegate.replaceAllButNumber(3);
                  }
                },
              ),
              SizedBox(
                width: size.width * 0.1,
              ),
              InkWell(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.25,
                    minHeight: size.height / 20,
                  ),
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.red,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Refuse",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  chatViewModel.denyPendingChat();
                  routerDelegate.replaceAllButNumber(4);
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
