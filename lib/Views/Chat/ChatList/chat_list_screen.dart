import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';

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

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
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
            // or the EmptyLandscapeBody depending on the value of the currentChat
            return VerticalSplitView(
              left: widget.chatListBody,
              right: ValueListenableBuilder(
                valueListenable: chatViewModel.currentChat,
                builder: (context, Chat? chat, child) {
                  // Check if the current chat is null
                  if (chat != null) {
                    return ChatPageBody(key: ValueKey(chat.peerUser!.id));
                  } else {
                    return EmptyLandscapeBody();
                  }
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
}
