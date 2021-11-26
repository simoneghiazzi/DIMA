import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Model/BaseUser/Diary/note.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DiaryPageBody extends StatefulWidget {
  final Note diaryNote;

  DiaryPageBody({Key key, this.diaryNote}) : super(key: key);

  @override
  _DiaryPageBodyState createState() => _DiaryPageBodyState();
}

class _DiaryPageBodyState extends State<DiaryPageBody> {
  DateTime today;
  Note note;
  DiaryViewModel diaryViewModel;
  BaseUserViewModel baseUserViewModel;
  AppRouterDelegate routerDelegate;
  Alert errorAlert;
  Alert successAlert;
  StreamSubscription<bool> subscription;
  bool modifiable = false;
  bool hasFocus = true;

  @override
  void initState() {
    DateTime now = DateTime.now();
    note = widget.diaryNote;
    today = DateTime(now.year, now.month, now.day);
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    errorAlert = createErrorAlert();
    successAlert = createSuccessAlert();
    subscription = subscribeToSuccessViewModel();
    BackButtonInterceptor.add(backButtonInterceptor);
    if (note == null) {
      modifiable = true;
    } else {
      diaryViewModel.setTextContent(note.title, note.content);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                      height: 340.0,
                      width: size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/icons/logo.png',
                          ),
                        ),
                      )),
                  Positioned(
                    top: size.height / 5,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.bottomLeft,
                        child: Center(
                            child: TextField(
                          autofocus: hasFocus,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                          enabled: modifiable,
                          controller: diaryViewModel.titleCtrl,
                          cursorColor: kPrimaryColor,
                          style: TextStyle(color: kPrimaryColor, fontSize: 25, fontWeight: FontWeight.bold, shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Colors.white,
                            ),
                          ]),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "What's out topic of discussion?",
                              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 25, fontWeight: FontWeight.bold, shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 5.0,
                                  color: Colors.white,
                                ),
                              ])),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                        ))),
                  ),
                  Positioned(
                    top: 300.0,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(100.0), topLeft: Radius.circular(100.0)),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(.4),
                              offset: Offset(0.0, -8),
                              blurRadius: 6,
                            )
                          ]),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 50.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: modifiable,
                  controller: diaryViewModel.contentCtrl,
                  cursorColor: kPrimaryColor,
                  style: TextStyle(color: kPrimaryColor, fontSize: 20),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Tell me about it...',
                    hintStyle: TextStyle(color: kPrimaryColor, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                child: InkResponse(
                  onTap: () {
                    diaryViewModel.clearControllers();
                    routerDelegate.pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(color: kPrimaryColor.withOpacity(.5), offset: Offset(1.0, 10.0), blurRadius: 10.0),
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: kPrimaryColor),
                  ),
                ),
              ),
            ),
          ),
          note != null && !modifiable
              ? Positioned(
                  bottom: 30,
                  right: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      note.date == today
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                              child: InkResponse(
                                onTap: () {
                                  setState(() {
                                    hasFocus = true;
                                    modifiable = true;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(color: kPrimaryColor.withOpacity(.5), offset: Offset(1.0, 10.0), blurRadius: 10.0),
                                    ],
                                  ),
                                  child: Icon(CupertinoIcons.pencil, color: kPrimaryColor),
                                ),
                              ))
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: InkResponse(
                          onTap: () {
                            note.favourite = !note.favourite;
                            diaryViewModel.setFavourite(note.id, note.favourite);
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(color: kPrimaryColor.withOpacity(.5), offset: Offset(1.0, 10.0), blurRadius: 10.0),
                              ],
                            ),
                            child: note.favourite
                                ? Icon(CupertinoIcons.heart_fill, color: kPrimaryColor)
                                : Icon(CupertinoIcons.heart, color: kPrimaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Align(
                  alignment: Alignment.bottomRight,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 45.0),
                      child: StreamBuilder(
                          stream: diaryViewModel.diaryForm.isButtonEnabled,
                          builder: (context, snapshot) {
                            if (snapshot.data ?? false || note != null) {
                              return InkResponse(
                                onTap: () {
                                  if (note != null) {
                                    diaryViewModel.submitPage(pageId: note.id, isFavourite: note.favourite);
                                  } else {
                                    diaryViewModel.submitPage();
                                  }
                                  setState(() {
                                    note = diaryViewModel.submittedNote;
                                    modifiable = false;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(color: kPrimaryColor.withOpacity(.5), offset: Offset(1.0, 10.0), blurRadius: 10.0),
                                    ],
                                  ),
                                  child: Icon(Icons.check, color: kPrimaryColor),
                                ),
                              );
                            }
                            return Container();
                          }),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  StreamSubscription<bool> subscribeToSuccessViewModel() {
    return diaryViewModel.isPageAdded.listen((isSuccessfulAdd) {
      if (isSuccessfulAdd) {
        successAlert.show();
      } else {
        errorAlert.show();
      }
    });
  }

  Alert createSuccessAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "Page submitted!",
      type: AlertType.success,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: kPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            successAlert.dismiss();
          },
          color: Colors.transparent,
        )
      ],
    );
  }

  Alert createErrorAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "AN ERROR OCCURED",
      type: AlertType.error,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            errorAlert.dismiss();
          },
          color: kPrimaryColor,
        )
      ],
    );
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    routerDelegate.pop();
    diaryViewModel.clearControllers();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    subscription.cancel();
    super.dispose();
  }
}

class EntryHeaderImage extends StatelessWidget {
  final String heroTag;
  final ImageProvider imageProvider;

  const EntryHeaderImage({
    Key key,
    this.heroTag,
    this.imageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: imageProvider,
      child: Container(
        height: 340.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(colorFilter: ColorFilter.mode(Color(0xFF3C4858), BlendMode.lighten), image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
