import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/BaseUser/PendingChatsList/pending_chats_list_screen.dart';
import 'package:sApport/Views/Chat/BaseUser/AnonymousChatsList/components/anonymous_chats_list_constructor.dart';

/// Body of the anonymous chat list page.
///
/// It contains the top bar with the listener for new requests, the anonymous chat list constructor and the button for searching new random users.
class AnonymousChatsListBody extends StatefulWidget {
  /// Body of the anonymous chat list page.
  ///
  /// It contains the top bar with the listener for new requests, the anonymous chat list constructor and the button for searching new random users.
  const AnonymousChatsListBody({Key? key}) : super(key: key);

  @override
  _AnonymousChatsListBodyState createState() => _AnonymousChatsListBodyState();
}

class _AnonymousChatsListBodyState extends State<AnonymousChatsListBody> {
  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // View Models
  late ChatViewModel chatViewModel;

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
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(
              back: chatViewModel.resetCurrentChat,
              text: "Anonymous",
              buttons: [
                // Listener for new pending chats
                Consumer<ChatViewModel>(
                  builder: (context, chatViewModel, child) {
                    if (chatViewModel.pendingChats.length != 0) {
                      // If there are pending chats, show the "Requests" button
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                          child: Row(children: <Widget>[
                            Icon(Icons.notification_add, color: kPrimaryGoldenColor, size: 20),
                            SizedBox(width: 2),
                            Text("Requests", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ]),
                        ),
                        onTap: () => routerDelegate.pushPage(name: PendingChatsListScreen.route),
                      );
                    } else
                      return Container();
                  },
                ),
              ],
            ),
            AnonymousChatsListConstructor(),
          ],
        ),
        // "+" button to look for new random users
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
