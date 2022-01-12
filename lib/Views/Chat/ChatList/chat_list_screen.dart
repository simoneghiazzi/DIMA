import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Profile/components/expert_profile_body.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/anonymous_chat_list_body.dart';

/// Page of the chat list of the user.
///
/// Based on the [chatListBody], it shows a specific chat list of the user.
///
/// It contains the [OrientationBuilder] that checks the orientation of the device and
/// rebuilds the page when the orientation changes. If it is:
/// - portrait: it displays the [chatListBody].
/// - landscape: it uses the [VerticalSplitView] for displayng the [chatListBody] on the left and the
/// [ChatPageBody] (if there is an active chat) on the right.
///
/// It subscribes to the chat view model currentChat value notifier in order to rebuild the right hand side of the page
/// when a new current chat is selected.
/// If the current chat is null, it shows the [EmptyLandscapeBody].
class ChatListScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/chatListScreen";

  /// Body of the page that contains the correct chat list.
  final Widget chatListBody;

  /// Page of the chat list of the user.
  ///
  /// Based on the [chatListBody], it shows a specific chat list of the user.
  ///
  /// It contains the [OrientationBuilder] that checks the orientation of the device and
  /// rebuilds the page when the orientation changes. If it is:
  /// - portrait: it displays the [chatListBody].
  /// - landscape: it uses the [VerticalSplitView] for displayng the [chatListBody] on the left and the
  /// [ChatPageBody] (if there is an active chat) on the right.
  ///
  /// It subscribes to the chat view model currentChat value notifier in order to rebuild the right hand side of the page
  /// when a new current chat is selected.
  /// If the current chat is null, it shows the [EmptyLandscapeBody].
  const ChatListScreen({Key? key, required this.chatListBody}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // View Models
  late ChatViewModel chatViewModel;
  late MapViewModel mapViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  Widget? splitRightWidget;
  var currentChat;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    // Add a back button interceptor for listening to the OS back button
    BackButtonInterceptor.add(backButtonInterceptor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            // If the orientation is protrait, shows the chatListBody
            return widget.chatListBody;
          } else {
            // If the orientation is landscape, shows the VerticalSplitView with the chatListBody on the left
            // and the ValueListenableBuilder listener on the right that builds the ChatPageBody
            // or the EmptyLandscapeBody depending on the value of the currentChat.
            // It contains also the ValueListenableBuilder that builds the ExpertProfilePage if the
            // current expert is setted inside the mapViewModel.
            return VerticalSplitView(
              left: widget.chatListBody,
              right: ValueListenableBuilder(
                valueListenable: chatViewModel.currentChat,
                builder: (context, Chat? chat, child) {
                  currentChat = chat;
                  return ValueListenableBuilder(
                    valueListenable: mapViewModel.currentExpert,
                    builder: (context, Expert? expert, child) {
                      // If the current expert is not null, show the ExpertProfileBody on the right
                      if (expert != null && expert == chatViewModel.currentChat.value?.peerUser) {
                        splitRightWidget = ExpertProfileBody();
                        return ExpertProfileBody();
                      }
                      // Check if the current chat is null or if it is the same chat of the chatListBody or it is a request
                      else if (chat != null && !(chat is PendingChat && widget.chatListBody is AnonymousChatListBody)) {
                        mapViewModel.resetCurrentExpert();
                        splitRightWidget = ChatPageBody();
                        return ChatPageBody(key: ValueKey(chat.peerUser!.id));
                      } else {
                        splitRightWidget = EmptyLandscapeBody();
                        return EmptyLandscapeBody();
                      }
                    },
                  );
                },
              ),
              ratio: 0.35,
              dividerWidth: 0.3,
              dividerColor: kPrimaryGreyColor,
            );
          }
        },
      ),
    );
  }

  /// Function called by the back button interceptor.
  ///
  /// It resets the `chatting with` field into the DB and the current chat of the [ChatViewModel]
  /// and finally pop the page if the right widget of the split screen is not the ExpertProfileBody.
  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      if (splitRightWidget != null && splitRightWidget is! ExpertProfileBody) {
        chatViewModel.resetCurrentChat();
        routerDelegate.pop();
      }
    } else {
      var lastRemovedRoute = routerDelegate.getLastRemovedRoute()?.name;
      if (lastRemovedRoute == null && routerDelegate.getLastRoute().name != ChatPageScreen.route) {
        routerDelegate.pop();
      }
    }
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
