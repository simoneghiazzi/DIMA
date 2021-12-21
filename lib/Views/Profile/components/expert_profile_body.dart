import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Views/Chat/BaseUser/ChatWithExperts/expert_chat_list_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertProfileBody extends StatefulWidget {
  final Expert? expert;

  ExpertProfileBody({Key? key, required this.expert}) : super(key: key);

  @override
  _ExpertProfileBodyState createState() => _ExpertProfileBodyState();
}

class _ExpertProfileBodyState extends State<ExpertProfileBody> {
  late ChatViewModel chatViewModel;
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // background image and bottom contents
          SingleChildScrollView(
              child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 40, bottom: 10),
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      routerDelegate.pop();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.transparent,
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 40.0),
                  ),
                ),
                alignment: Alignment.topLeft,
                height: 150.0,
                width: 100.w,
                color: kPrimaryColor,
              ),
              Container(
                  transform: Matrix4.translationValues(0.0, -75.0, 0.0),
                  child: NetworkAvatar(
                    img: widget.expert!.profilePhoto,
                    radius: 75.0,
                  )),
              Container(
                transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: kPrimaryLightColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.expert!.name.toUpperCase() + " " + widget.expert!.surname.toUpperCase(),
                                style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 7.h,
                          ),
                          // Phone number
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.phone,
                                color: kPrimaryColor,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              GestureDetector(
                                child: Text(widget.expert!.phoneNumber,
                                    style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
                                onTap: () {
                                  launch('tel://' + widget.expert!.phoneNumber);
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          // Email
                          Row(
                            children: [
                              Icon(
                                Icons.mail,
                                color: kPrimaryColor,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Flexible(
                                child: GestureDetector(
                                  child:
                                      Text(widget.expert!.email, style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
                                  onTap: () async {
                                    EmailContent email = EmailContent(
                                      to: [
                                        widget.expert!.email,
                                      ],
                                    );

                                    // Android: Will open mail app or show native picker.
                                    // iOS: Will open mail app if single mail app found.
                                    OpenMailAppResult result = await OpenMailApp.composeNewEmailInMailApp(
                                        nativePickerTitle: 'Select email app to compose', emailContent: email);

                                    // If no mail apps found, show error
                                    if (!result.didOpen && !result.canOpen) {
                                      showNoMailAppsDialog(context);

                                      // iOS: if multiple mail apps found, show dialog to select.
                                      // There is no native intent/default app system in iOS so
                                      // you have to do it yourself.
                                    } else if (!result.didOpen && result.canOpen) {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return MailAppPickerDialog(
                                            mailApps: result.options,
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          // Address
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.house,
                                color: kPrimaryColor,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Flexible(
                                child: GestureDetector(
                                  child:
                                      Text(widget.expert!.address, style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
                                  onTap: () {
                                    openMaps();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 7.h,
                          ),
                          Divider(
                            color: kPrimaryColor,
                            height: 1.5,
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                        ],
                      ),
                      Center(
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                            height: 5.h,
                            width: 5.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kPrimaryColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Get in Touch",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            chatViewModel.setCurrentChat(ExpertChat(peerUser: widget.expert!));
                            if (SizerUtil.orientation == Orientation.portrait) {
                              routerDelegate.replaceAllButNumber(2, routeSettingsList: [
                                RouteSettings(name: ExpertChatsListScreen.route),
                                RouteSettings(name: ChatPageScreen.route),
                              ]);
                            } else {
                              routerDelegate.replaceAllButNumber(2, routeSettingsList: [RouteSettings(name: ExpertChatsListScreen.route)]);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () {
                  routerDelegate.pop();
                },
                child: Text("OK"))
          ],
        );
      },
    );
  }

  void openMaps() async {
    var lat = widget.expert!.latitude;
    var lng = widget.expert!.longitude;
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}
