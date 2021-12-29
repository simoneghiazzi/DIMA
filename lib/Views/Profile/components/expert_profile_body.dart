import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Settings/components/user_settings_body.dart';
import 'package:sApport/Views/components/info_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/expert_chat_list_body.dart';

/// Body of the [ExpertProfileScreen].
///
/// It contains all the base information of the [expert] and the
/// "Get in touch" button for opening a new chat with that expert.
///
/// It manages the opening of the navigator, the phone and the email
/// apps when the user clicks the relative information.
class ExpertProfileBody extends StatefulWidget {
  final Expert expert;

  /// Body of the [ExpertProfileScreen].
  ///
  /// It contains all the base information of the [expert] and the
  /// "Get in touch" button for opening a new chat with that expert.
  ///
  /// It manages the opening of the navigator, the phone and the email
  /// apps when the user clicks the relative information.
  const ExpertProfileBody({Key? key, required this.expert}) : super(key: key);

  @override
  _ExpertProfileBodyState createState() => _ExpertProfileBodyState();
}

class _ExpertProfileBodyState extends State<ExpertProfileBody> {
  // View Models
  late ChatViewModel chatViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Top Bar with Image
        Row(
          children: [
            Expanded(
              child: Container(
                color: kPrimaryColor,
                child: SafeArea(
                  child: Container(
                    height: 18.h,
                    color: kPrimaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        Padding(
                          padding: EdgeInsets.only(top: 15.0, left: 10.0),
                          child: IconButton(
                            icon: Icon(Icons.close, size: 35.0, color: Colors.white),
                            onPressed: () => routerDelegate.pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Profile photo
        Container(
          transform: Matrix4.translationValues(0.0, -75.0, 0.0),
          child: NetworkAvatar(img: widget.expert.profilePhoto, radius: 75.0),
        ),
        // Full Name
        Container(
          transform: Matrix4.translationValues(0.0, -50.0, 0.0),
          width: 70.w,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: kPrimaryLightColor),
          child: Text(
            widget.expert.fullName.toUpperCase(),
            style: TextStyle(color: kPrimaryColor, fontSize: 17.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Container(
            transform: Matrix4.translationValues(0.0, -40.0, 0.0),
            padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 3.w),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: ListView(
                physics: (MediaQuery.of(context).orientation == Orientation.portrait) ? const NeverScrollableScrollPhysics() : null,
                children: [
                  // Email
                  Row(
                    children: [
                      Icon(Icons.mail, color: kPrimaryColor),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: GestureDetector(
                          child: Text(widget.expert.email, style: TextStyle(color: kPrimaryColor, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          onTap: () async {
                            EmailContent email = EmailContent(to: [widget.expert.email]);
                            // Android: Will open mail app or show native picker.
                            // iOS: Will open mail app if single mail app found.
                            OpenMailAppResult result = await OpenMailApp.composeNewEmailInMailApp(
                              nativePickerTitle: "Select email app to compose",
                              emailContent: email,
                            );
                            // If no mail apps found, show error
                            if (!result.didOpen && !result.canOpen) {
                              InfoDialog.show(context, infoType: InfoDialogType.error, content: "No mail apps installed.", buttonType: ButtonType.ok);
                              // iOS: if multiple mail apps found, show dialog to select.
                              // There is no native intent/default app system in iOS so
                              // you have to do it yourself.
                            } else if (!result.didOpen && result.canOpen) {
                              showDialog(
                                context: context,
                                builder: (_) => MailAppPickerDialog(mailApps: result.options),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.5.h),
                  // Phone Number
                  Row(
                    children: <Widget>[
                      Icon(Icons.phone, color: kPrimaryColor),
                      SizedBox(width: 5.w),
                      GestureDetector(
                        child: Text(widget.expert.phoneNumber, style: TextStyle(color: kPrimaryColor, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        onTap: () {
                          launch("tel:// + ${widget.expert.phoneNumber}");
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  // Address
                  Row(
                    children: <Widget>[
                      Icon(Icons.house, color: kPrimaryColor),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: GestureDetector(
                          child: Text(widget.expert.address, style: TextStyle(color: kPrimaryColor, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          onTap: () => openMaps(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Divider(color: kPrimaryColor, height: 1.5),
                  (MediaQuery.of(context).orientation == Orientation.landscape)
                      // Get In Touch Button
                      ? Container(
                          child: RoundedButton(
                            text: "Get In Touch ",
                            onTap: () {
                              chatViewModel.addNewChat(ExpertChat(peerUser: widget.expert));
                              if (MediaQuery.of(context).orientation == Orientation.portrait) {
                                // If orientation is portrait, above the home page push the ChatListScreen with the experts and the ChatPageScreen
                                routerDelegate.replaceAllButNumber(2, routeSettingsList: [
                                  RouteSettings(name: ChatListScreen.route, arguments: ExpertChatListBody()),
                                  RouteSettings(name: ChatPageScreen.route),
                                ]);
                              } else {
                                // Otherwise, above the home page push only the ChatListScreen with the experts
                                routerDelegate.replaceAllButNumber(2, routeSettingsList: [
                                  RouteSettings(name: ChatListScreen.route, arguments: ExpertChatListBody()),
                                ]);
                              }
                            },
                            suffixIcon: Icon(Icons.chat, color: Colors.white, size: 20),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
        ),
        (MediaQuery.of(context).orientation == Orientation.portrait)
            // Get In Touch Button
            ? Container(
                child: RoundedButton(
                  text: "Get In Touch ",
                  onTap: () {
                    chatViewModel.addNewChat(ExpertChat(peerUser: widget.expert));
                    if (MediaQuery.of(context).orientation == Orientation.portrait) {
                      // If orientation is portrait, above the home page push the ChatListScreen with the experts and the ChatPageScreen
                      routerDelegate.replaceAllButNumber(2, routeSettingsList: [
                        RouteSettings(name: ChatListScreen.route, arguments: ExpertChatListBody()),
                        RouteSettings(name: ChatPageScreen.route),
                      ]);
                    } else {
                      // Otherwise, above the home page push only the ChatListScreen with the experts
                      routerDelegate.replaceAllButNumber(2, routeSettingsList: [
                        RouteSettings(name: ChatListScreen.route, arguments: ExpertChatListBody()),
                      ]);
                    }
                  },
                  suffixIcon: Icon(Icons.chat, color: Colors.white, size: 20),
                ),
              )
            : Container(),
        SizedBox(height: 10.h),
      ],
    );
  }

  /// Open the map with the information of the destination address.
  void openMaps() async {
    var lat = widget.expert.latitude;
    var lng = widget.expert.longitude;
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw "Could not launch ${uri.toString()}";
    }
  }
}
