import 'package:intl/intl.dart';
import 'package:sApport/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_constructor.dart';

/// Chat item of the [ChatListConstructor].
///
/// It takes the [chatItem] from the ListView builder that represents a chat of the user.
/// It contains the avatar, the name, the last message, the last message date time and the not read messages.
///
/// It also checks if the [chatItem] is equal to the current chat in order to automatically set the messages has read.
///
/// If the item is pressed and the current chat is different from the [chatItem], it sets the new current chat
/// equals to the [chatItem], it calls the [selectedItemCallback] and finally if the orientation of the device is
/// portrait, it push the [ChatPageScreen].
class ChatListItem extends StatefulWidget {
  final Chat chatItem;
  final Function selectedItemCallback;

  /// Chat item of the [ChatListConstructor].
  ///
  /// It takes the [chatItem] from the ListView builder that represents a chat of the user.
  /// It contains the avatar, the name, the last message, the last message date time and the not read messages.
  ///
  /// It also checks if the [chatItem] is equal to the current chat in order to automatically set the messages has read.
  ///
  /// If the item is pressed and the current chat is different from the [chatItem], it sets the new current chat
  /// equals to the [chatItem], it calls the [selectedItemCallback] and finally if the orientation of the device is
  /// portrait, it push the [ChatPageScreen].
  const ChatListItem({Key? key, required this.chatItem, required this.selectedItemCallback}) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  // View Models
  late UserViewModel userViewModel;
  late ChatViewModel chatViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  late bool isSelected;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isSelected = chatViewModel.currentChat.value?.peerUser?.id == widget.chatItem.peerUser!.id;
    // If the chat is the same as the currentChat (the peerUser is the same) and the not read messages are > 0,
    // set the messages has read
    if (widget.chatItem.notReadMessages > 0 && widget.chatItem.peerUser == chatViewModel.currentChat.value?.peerUser) {
      widget.chatItem.notReadMessages = 0;
      chatViewModel.setMessagesHasRead();
    }
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 1.w),
                  // Avatar
                  widget.chatItem.peerUser is BaseUser
                      ?
                      // If the peer user is a BaseUser, show the logo circle avatar
                      CircleAvatar(backgroundColor: Colors.transparent, radius: 25.0, child: Image.asset("assets/icons/logo.png", scale: 11))
                      :
                      // If the peer user is an Expert, show the network avatar with the user profile photo
                      NetworkAvatar(img: widget.chatItem.peerUser!.data['profilePhoto'].toString(), radius: 25.0),
                  SizedBox(width: 3.w),
                  // Profile info and lastMessage
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userViewModel.loggedUser is Expert || widget.chatItem.peerUser is Expert
                              ?
                              // If the logged user or the peer user is an Expert, show the full name of the peer user
                              "${widget.chatItem.peerUser!.fullName}"
                              :
                              // Otherwise, show only the name of the peer user
                              "${widget.chatItem.peerUser!.name}",
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(color: kPrimaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          widget.chatItem.lastMessage,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 11.sp, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // lastMessageDateTime and number of notReadMessages
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Utils.isToday(widget.chatItem.lastMessageDateTime!)
                        ?
                        // If the message date time is today, show the clock time
                        DateFormat("HH:mm").format(widget.chatItem.lastMessageDateTime!)
                        :
                        // Otherwise, show the date
                        DateFormat("MM/dd/yyyy").format(widget.chatItem.lastMessageDateTime!),
                    style: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 10.sp, fontStyle: FontStyle.italic),
                  ),
                  // Check if there are not read messages
                  if (widget.chatItem.notReadMessages > 0) ...[
                    SizedBox(height: 1.h),
                    Container(
                      constraints: BoxConstraints(maxHeight: 22, maxWidth: 22),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.red[600]),
                      child: Center(
                        child: Text(
                          widget.chatItem.notReadMessages.toString(),
                          style: TextStyle(fontSize: 9.3.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        onPressed: () {
          // If the chat is different from the current chat, set the new current chat and call the selected item callback
          if (chatViewModel.currentChat.value?.peerUser?.id != widget.chatItem.peerUser?.id) {
            chatViewModel.setCurrentChat(widget.chatItem);
            widget.selectedItemCallback();
            // If the orientation of the device is portrait, push the ChatPageScreen
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              routerDelegate.pushPage(name: ChatPageScreen.route);
            }
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              isSelected && MediaQuery.of(context).orientation == Orientation.landscape ? kPrimaryButtonColor : kPrimaryLightColor),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
        ),
      ),
    );
  }
}
