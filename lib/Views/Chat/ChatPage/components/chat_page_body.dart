import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_top_bar.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_text_input.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_accept_deny.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_constructor.dart';

/// It contains the [ChatTopBar] that differs based on the type of the peer user ([BaseUser] or [Expert]),
/// the [MessageListConstructor] of the messages between the 2 users and the [ChatTextInput] or the
/// [ChatAcceptDenyInput] if the chat is a new [PendingChat].
class ChatPageBody extends StatefulWidget {
  /// It contains the [ChatTopBar] that differs based on the type of the peer user ([BaseUser] or [Expert]),
  /// the [MessageListConstructor] of the messages between the 2 users and the [ChatTextInput] or the
  /// [ChatAcceptDenyInput] if the chat is a new [PendingChat].
  const ChatPageBody({Key? key}) : super(key: key);

  @override
  _ChatPageBodyState createState() => _ChatPageBodyState();
}

class _ChatPageBodyState extends State<ChatPageBody> with WidgetsBindingObserver {
  // View Models
  late UserViewModel userViewModel;
  late ChatViewModel chatViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Scroll Controller
  final ScrollController scrollController = ScrollController();

  Chat? currentChat;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    // Add an observer to this class for listening to the app lifecycle
    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        chatViewModel.currentChat.value!.peerUser is BaseUser
            ?
            // If the peer user is a BaseUser, show the icon circle avatar
            ChatTopBar.circleAvatar(
                text: userViewModel.loggedUser is Expert
                    ?
                    // If the logged user is an Expert, show the full name of the peer BaseUser
                    "${chatViewModel.currentChat.value!.peerUser!.fullName}"
                    :
                    // If the logged user is a BaseUser, show only the name of the peer BaseUser
                    "${chatViewModel.currentChat.value!.peerUser!.name}",
                circleAvatar: CircleAvatar(
                    radius: 3.1.h, backgroundColor: Colors.transparent, child: Icon(Icons.account_circle, size: 45, color: Colors.white)),
              )
            :
            // If the peer user is an Expert, show his/her profile photo as a network avatar and the full name
            ChatTopBar.networkAvatar(
                text: "${chatViewModel.currentChat.value!.peerUser!.fullName}",
                networkAvatar: NetworkAvatar(img: chatViewModel.currentChat.value!.peerUser!.data["profilePhoto"] as String, radius: 3.2.h),
              ),
        Expanded(
          child: Container(
            // Background image of the chat page
            decoration:
                BoxDecoration(color: kBackgroundColor, image: DecorationImage(image: AssetImage("assets/icons/logo.png"), scale: 8, opacity: 0.1)),
            child: Column(
              children: [
                // List of messages
                Flexible(
                    child: Padding(
                  padding: EdgeInsets.only(left: 1.w, right: 1.w),
                  child: MessageListConstructor(scrollController: scrollController),
                )),
                // Input content
                chatViewModel.currentChat.value is PendingChat
                    ?
                    // If the current chat is a pending chat, show the accept deny buttons
                    ChatAcceptDenyInput()
                    :
                    // Otherwise, show the chat text input
                    ChatTextInput(scrollController: scrollController),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the app is resumed, update the `chatting with` field into the DB, otherwise reset it
    if (state == AppLifecycleState.resumed) {
      chatViewModel.setCurrentChat(currentChat!);
    } else {
      currentChat = chatViewModel.currentChat.value;
      chatViewModel.resetCurrentChat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
