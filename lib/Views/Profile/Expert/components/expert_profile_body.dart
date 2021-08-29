import 'package:dima_colombo_ghiazzi/Model/Chat/active_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Chat/expert_chat.dart';
import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertProfileBody extends StatelessWidget {
  final ChatViewModel chatViewModel;
  final Expert expert;

  ExpertProfileBody(
      {Key key, @required this.chatViewModel, @required this.expert})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // background image and bottom contents
        Column(
          children: <Widget>[
            Container(
              height: 165.0,
              color: kPrimaryColor,
            ),
            SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(top: 90),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: size.width / 10, right: size.width / 10),
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryLightColor,
                              ),
                              child: Center(
                                  child: Flexible(
                                      child: Text(
                                expert.name.toUpperCase() +
                                    " " +
                                    expert.surname.toUpperCase(),
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                            ),
                            Column(
                              children: <Widget>[
                                SizedBox(
                                  height: size.height * 0.06,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.phone,
                                      color: kPrimaryColor,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    GestureDetector(
                                      child: Text(expert.phoneNumber,
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      onTap: () {
                                        launch('tel://' + expert.phoneNumber);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.06,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.mail,
                                      color: kPrimaryColor,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Flexible(
                                      child: GestureDetector(
                                        child: Text(expert.email,
                                            style: TextStyle(
                                                color: kPrimaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        onTap: () async {
                                          EmailContent email = EmailContent(
                                            to: [
                                              expert.email,
                                            ],
                                          );

                                          // Android: Will open mail app or show native picker.
                                          // iOS: Will open mail app if single mail app found.
                                          OpenMailAppResult result =
                                              await OpenMailApp
                                                  .composeNewEmailInMailApp(
                                                      nativePickerTitle:
                                                          'Select email app to compose',
                                                      emailContent: email);

                                          // If no mail apps found, show error
                                          if (!result.didOpen &&
                                              !result.canOpen) {
                                            showNoMailAppsDialog(context);

                                            // iOS: if multiple mail apps found, show dialog to select.
                                            // There is no native intent/default app system in iOS so
                                            // you have to do it yourself.
                                          } else if (!result.didOpen &&
                                              result.canOpen) {
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
                                  height: size.height * 0.06,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.house,
                                      color: kPrimaryColor,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Flexible(
                                      child: GestureDetector(
                                        child: Text(expert.address,
                                            style: TextStyle(
                                                color: kPrimaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        onTap: () {
                                          openMaps();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.06,
                                ),
                                Divider(
                                  color: kPrimaryColor,
                                  height: 1.5,
                                ),
                                SizedBox(
                                  height: size.height * 0.06,
                                ),
                                Center(
                                  child: InkWell(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 8, right: 8, top: 2, bottom: 2),
                                      height: size.height * 0.05,
                                      width: size.width * 0.5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: kPrimaryColor,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Get in touch",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Icon(
                                            Icons.message,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      initExpertChats();
                                      chatViewModel.chatWithUser(expert);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPageScreen(
                                            chatViewModel: chatViewModel,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )))
          ],
        ),
        // Profile image
        Positioned(
          top: 100.0, // (background container size) - (circle height / 2)
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.network(
                expert.getData()['profilePhoto'],
                fit: BoxFit.cover,
                width: 120.0,
                height: 120.0,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 120.0,
                    height: 120.0,
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                      value: loadingProgress.expectedTotalBytes != null &&
                              loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, object, stackTrace) {
                  return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        "${expert.name[0]}",
                        style: TextStyle(color: kPrimaryColor, fontSize: 30),
                      ));
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 25,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              Navigator.pop(context);
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.transparent,
            child: const Icon(Icons.arrow_back, size: 40.0),
          ),
        ),
      ],
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
                  Navigator.pop(context);
                },
                child: Text("OK"))
          ],
        );
      },
    );
  }

  void initExpertChats() {
    chatViewModel.conversation.senderUserChat = ExpertChat();
    chatViewModel.conversation.peerUserChat = ActiveChat();
  }

  void openMaps() async {
    var lat = expert.latLng.latitude;
    var lng = expert.latLng.longitude;
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}
