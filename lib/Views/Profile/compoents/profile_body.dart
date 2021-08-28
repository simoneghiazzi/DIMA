import 'package:dima_colombo_ghiazzi/Model/Expert/expert.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';

class ProfileBody extends StatelessWidget {
  final ChatViewModel chatViewModel;
  final Expert expert;

  ProfileBody({Key key, @required this.chatViewModel, @required this.expert})
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
              height: 250.0,
              color: kPrimaryColor,
            ),
            Padding(
                padding: EdgeInsets.only(top: 110),
                child: Container(
                  padding: EdgeInsets.only(
                      left: size.width / 7, right: size.width / 7),
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
                              child: Text(
                                  expert.name.toUpperCase() +
                                      " " +
                                      expert.surname.toUpperCase(),
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold))),
                        ),
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        Text(expert.phoneNumber,
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 20,
                            )),
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        GestureDetector(
                          child: Text("QUI EMAIL",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          onTap: () async {
                            EmailContent email = EmailContent(
                              to: [
                                'ANCHE QUI MAIL',
                              ],
                            );

                            // Android: Will open mail app or show native picker.
                            // iOS: Will open mail app if single mail app found.
                            OpenMailAppResult result =
                                await OpenMailApp.composeNewEmailInMailApp(
                                    nativePickerTitle:
                                        'Select email app to compose',
                                    emailContent: email);

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
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        Text("QUI INDIRIZZO",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 20,
                            )),
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        Divider(
                          color: kPrimaryColor,
                          height: 1.5,
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ),
        // Profile image
        Positioned(
            top: 140.0, // (background container size) - (circle height / 2)
            child: CircleAvatar(
              radius: 90,
              backgroundColor: kPrimaryLightColor,
              backgroundImage: NetworkImage(expert.profilePhoto),
            )),
        Positioned(
          top: 60,
          left: 20,
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
        Positioned(
            bottom: 40,
            child: Column(
              children: <Widget>[
                Text("Get in touch",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: size.height * 0.02,
                ),
                RoundedButton(text: "CHAT", press: () {})
              ],
            ))
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
}
