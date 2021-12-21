import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Chat/components/chat_list_constructor.dart';

/// Body of the experts chat list page.
///
/// It contains the top bar, the chat list constructor of the experts chats and the button for searching new experts.
class ExpertChatListBody extends StatefulWidget {
  /// Body of the experts chat list page.
  ///
  /// It contains the top bar, the chat list constructor of the experts chats and the button for searching new experts.
  const ExpertChatListBody({Key? key}) : super(key: key);

  @override
  _ExpertChatListBodyState createState() => _ExpertChatListBodyState();
}

class _ExpertChatListBodyState extends State<ExpertChatListBody> {
  // View Models
  late ChatViewModel chatViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(back: chatViewModel.resetCurrentChat, text: "Experts"),
            ChatListConstructor(valueNotifier: chatViewModel.expertChats),
          ],
        ),
        // "+" button used to look for new expert
        Align(
          alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1)!,
          child: FloatingActionButton(
            onPressed: () => routerDelegate.pushPage(name: MapScreen.route),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.add, size: 40.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
