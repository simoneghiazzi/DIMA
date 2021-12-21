import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_page_body.dart';
import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/components/expert_chats_list_body.dart';

/// List of the chats with experts of the user.
///
/// If the orientation of the device is:
/// - portrait: it displays the [ExpertChatsListBody].
/// - landscape: it uses the [VerticalSplitView] for displayng the [ExpertChatsListBody] on the left and the
/// [ChatPageBody] (if there is an active chat) on the right.
///
/// It subscribes to the chat view model currentChat value notifier in order to rebuild the right hand side of the page
/// when a new current chat is selected.
/// If the current chat is null, it shows the [EmptyLandscapeBody].
class ExpertChatsListScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/expertChatsListScreen";

  /// List of the chats with experts of the user.
  ///
  /// If the orientation of the device is:
  /// - portrait: it displays the [ExpertChatsListBody].
  /// - landscape: it uses the [VerticalSplitView] for displayng the [ExpertChatsListBody] on the left and the
  /// [ChatPageBody] (if there is an active chat) on the right.
  ///
  /// It subscribes to the chat view model currentChat value notifier in order to rebuild the right hand side of the page
  /// when a new current chat is selected.
  /// If the current chat is null, it shows the [EmptyLandscapeBody].
  const ExpertChatsListScreen({Key? key}) : super(key: key);

  @override
  State<ExpertChatsListScreen> createState() => _ExpertChatsListScreenState();
}

class _ExpertChatsListScreenState extends State<ExpertChatsListScreen> {
  late ChatViewModel chatViewModel;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ?
          // If the orientation is protrait, shows the AnonymousChatsListBody
          ExpertChatsListBody()
          :
          // If the orientation is landscape, shows the VerticalSplitView with the AnonymousChatsListBody
          // on the left and the Consumer<ChatViewModel> listener on the right
          VerticalSplitView(
              left: ExpertChatsListBody(),
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
            ),
    );
  }
}
