import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:sApport/Model/BaseUser/Diary/note.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/components/top_bar.dart';
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
  String title;
  DateFormat formatter = DateFormat('dd MMM yyyy');

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
      DateTime now = DateTime.now();
      title = formatter.format(now);
    } else {
      diaryViewModel.setTextContent(note.title, note.content);
      title = formatter.format(note.date);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  text: title,
                  back: () {
                    diaryViewModel.clearControllers();
                    routerDelegate.pop();
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0),
                  child: TextField(
                    autofocus: hasFocus,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: modifiable,
                    controller: diaryViewModel.titleCtrl,
                    cursorColor: kPrimaryColor,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "What's out topic of discussion?",
                      hintStyle: TextStyle(
                        color: kPrimaryDarkColorTrasparent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: size.width * 0.9,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: kPrimaryColor,
                            height: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 32),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    enabled: modifiable,
                    controller: diaryViewModel.contentCtrl,
                    cursorColor: kPrimaryColor,
                    style: TextStyle(color: kPrimaryColor, fontSize: 18),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Tell me about it...',
                      hintStyle: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.topLeft),
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
