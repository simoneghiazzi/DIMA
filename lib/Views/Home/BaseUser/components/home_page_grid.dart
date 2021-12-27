import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/expert_chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/anonymous_chat_list_body.dart';

/// Grid of the [BaseUserHomePageScreen].
///
/// It contains the [DashCard]s that compose the grid.
class HomePageGrid extends StatelessWidget {
  /// Grid of the [BaseUserHomePageScreen].
  ///
  /// It contains the [DashCard]s that compose the grid.
  const HomePageGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Router Delegate
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return Center(
      child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Table(
            children: [
              TableRow(children: <Widget>[
                // Expert Chats
                DashCard(
                  imagePath: "assets/icons/psychologist.png",
                  text: "Experts\nchats",
                  onTap: () => routerDelegate.pushPage(name: ChatListScreen.route, arguments: ExpertChatListBody()),
                ),
                // Anonymous Chats
                DashCard(
                  imagePath: "assets/icons/anonymous.png",
                  text: "Anonymous\nchats",
                  onTap: () => routerDelegate.pushPage(name: ChatListScreen.route, arguments: AnonymousChatListBody()),
                ),
              ]),
              TableRow(children: <Widget>[
                // Map
                DashCard(
                  imagePath: "assets/icons/map.png",
                  text: "Find an\nexpert",
                  onTap: () => routerDelegate.pushPage(name: MapScreen.route),
                ),
                // Reports
                DashCard(
                  imagePath: "assets/icons/report.png",
                  text: "Anonymous\nreports",
                  onTap: () => routerDelegate.pushPage(name: CreateReportScreen.route),
                ),
              ])
            ],
          )),
    );
  }
}
