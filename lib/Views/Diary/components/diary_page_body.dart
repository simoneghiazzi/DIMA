import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:sApport/Model/BaseUser/Diary/diary_page.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DiaryPageBody extends StatefulWidget {
  const DiaryPageBody({Key key}) : super(key: key);

  @override
  _DiaryPageBodyState createState() => _DiaryPageBodyState();
}

class _DiaryPageBodyState extends State<DiaryPageBody> {
  DiaryViewModel diaryViewModel;
  DateTime today;
  AppRouterDelegate routerDelegate;
  Alert errorAlert;
  Alert successAlert;
  StreamSubscription<bool> subscription;
  bool modifiable = false;
  bool hasFocus = true;
  String title;
  DateFormat formatter = DateFormat('dd MMM yyyy');

  DiaryPage _diaryPageItem;

  @override
  void initState() {
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    errorAlert = createErrorAlert();
    successAlert = createSuccessAlert();
    subscription = subscribeToSuccessViewModel();
    BackButtonInterceptor.add(backButtonInterceptor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_diaryPageItem == null) {
      modifiable = true;
      DateTime now = DateTime.now();
      title = formatter.format(now);
    } else {
      diaryViewModel.setTextContent(_diaryPageItem.title, _diaryPageItem.content);
      title = formatter.format(_diaryPageItem.dateTime);
    }
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              text: title,
              isPortrait: MediaQuery.of(context).orientation == Orientation.landscape,
              back: diaryViewModel.clearControllers,
              buttons: [
                if (_diaryPageItem != null && !modifiable && _diaryPageItem.dateTime == today)
                  InkWell(
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
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: Colors.white),
                    ),
                  )),
                if (_diaryPageItem != null && !modifiable)
                  InkWell(
                    child: InkResponse(
                      onTap: () {
                        _diaryPageItem.favourite = !_diaryPageItem.favourite;
                        diaryViewModel.setFavourite(_diaryPageItem.id, _diaryPageItem.favourite);
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: _diaryPageItem.favourite
                            ? Icon(CupertinoIcons.heart_fill, color: Colors.white)
                            : Icon(CupertinoIcons.heart, color: Colors.white),
                      ),
                    ),
                  ),
                if (modifiable)
                  InkWell(
                    child: StreamBuilder(
                        stream: diaryViewModel.diaryForm.isButtonEnabled,
                        builder: (context, snapshot) {
                          if (snapshot.data ?? false || _diaryPageItem != null) {
                            return InkResponse(
                              onTap: () {
                                if (_diaryPageItem != null) {
                                  diaryViewModel.updatePage(_diaryPageItem.id);
                                } else {
                                  diaryViewModel.submitPage();
                                }
                                setState(() {
                                  //note = diaryViewModel.submittedNote;
                                  modifiable = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            );
                          }
                          return Container();
                        }),
                  )
              ],
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -5.0, 0.0),
              height: size.height / 2,
              color: kPrimaryColor,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: size.height / 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(color: kPrimaryColor.withOpacity(.5), blurRadius: 10.0),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    autofocus: hasFocus,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: modifiable,
                    controller: diaryViewModel.titleTextCtrl,
                    cursorColor: kPrimaryColor,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 25,
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        enabled: modifiable,
                        controller: diaryViewModel.contentTextCtrl,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  // Future<void> detectChangeOrientation() async {
  //   if (widget.startOrientation != (MediaQuery.of(context).orientation == Orientation.landscape)) {
  //     widget.startOrientation = true;
  //     await Future(() async {
  //       routerDelegate.pop();
  //     });
  //   }
  // }

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
