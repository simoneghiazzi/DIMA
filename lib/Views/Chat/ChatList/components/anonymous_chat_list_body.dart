import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_constructor.dart';
import 'package:sApport/Views/Chat/ChatList/components/pending_chat_list_body.dart';

/// It contains the [TopBar] with the [ValueListenableBuilder] in order to listen for new requests,
/// the [ChatListConstructor] of the anonymous chats and the button for searching new random users.
class AnonymousChatListBody extends StatefulWidget {
  /// It contains the [TopBar] with the [ValueListenableBuilder] in order to listen for new requests,
  /// the [ChatListConstructor] of the anonymous chats and the button for searching new random users.
  const AnonymousChatListBody({Key? key}) : super(key: key);

  @override
  _AnonymousChatListBodyState createState() => _AnonymousChatListBodyState();
}

class _AnonymousChatListBodyState extends State<AnonymousChatListBody> {
  // View Models
  late ChatViewModel chatViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Streams
  late StreamSubscription<bool> subscriberNewRandomUser;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    subscriberNewRandomUser = subscribeToNewRandomUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(
              onBack: () {
                chatViewModel.resetCurrentChat();
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              },
              text: "Anonymous",
              buttons: [
                // Listener for new pending chats
                ValueListenableBuilder(
                  valueListenable: chatViewModel.pendingChats!,
                  builder: (context, LinkedHashMap<String, Chat> pendingChats, child) {
                    if (pendingChats.length != 0) {
                      // If there are pending chats, show the "Requests" button
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                          child: Row(children: <Widget>[
                            Icon(Icons.notification_add, color: kPrimaryGoldenColor, size: 20),
                            SizedBox(width: 2),
                            Text("Requests", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          ]),
                        ),
                        onTap: () => routerDelegate.pushPage(name: ChatListScreen.route, arguments: PendingChatListBody()),
                      );
                    } else
                      return Container();
                  },
                ),
              ],
            ),
            ChatListConstructor(valueNotifier: chatViewModel.anonymousChats!),
          ],
        ),
        // "+" button used to look for new random users
        Align(
          alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1)!,
          child: FloatingActionButton(
            onPressed: () {
              LoadingDialog.show(context, text: "Looking for new random user...");
              chatViewModel.getNewRandomUser();
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.add, size: 40.0, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Subscriber to the stream of new random user. It returns a [StreamSubscription].
  ///
  /// If a user is found and the orientation is portrait, it push the chat page.
  /// If the user is not found, it shows a snack bar.
  StreamSubscription<bool> subscribeToNewRandomUser() {
    return chatViewModel.newRandomUser.listen((isNewRandomUser) {
      LoadingDialog.hide(context);
      if (isNewRandomUser) {
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          routerDelegate.pushPage(name: ChatPageScreen.route);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("No match found."), duration: const Duration(seconds: 5)));
      }
    });
  }

  @override
  void dispose() {
    subscriberNewRandomUser.cancel();
    super.dispose();
  }
}
