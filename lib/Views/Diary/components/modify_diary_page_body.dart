import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ModifyDiaryPageBody extends StatefulWidget {
  final DiaryViewModel diaryViewModel;
  final Note diaryNote;

  ModifyDiaryPageBody(
      {Key key, @required this.diaryViewModel, @required this.diaryNote})
      : super(key: key);

  _ModifyDiaryPageBodyState createState() => _ModifyDiaryPageBodyState();
}

class _ModifyDiaryPageBodyState extends State<ModifyDiaryPageBody>
    with SingleTickerProviderStateMixin {
  AnimationController _optionsAnimationController;
  Animation<Offset> _optionsAnimation, _optionsDelayedAnimation;
  bool _optionsIsOpen = false;

  BaseUserViewModel baseUserViewModel;
  AppRouterDelegate routerDelegate;
  Alert errorAlert;
  Alert successAlert;
  StreamSubscription<bool> subscription;

  @override
  void initState() {
    _optionsAnimationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _optionsAnimation = Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _optionsAnimationController, curve: Curves.easeOutBack))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener(_setOptionsStatus);
    _optionsDelayedAnimation =
        Tween<Offset>(begin: Offset(100, 0), end: Offset(0, 0)).animate(
            CurvedAnimation(
                parent: _optionsAnimationController,
                curve: Interval(0.2, 1.0, curve: Curves.easeOutBack)));
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    errorAlert = createErrorAlert();
    successAlert = createSuccessAlert();
    subscription = subscribeToSuccessViewModel();

    widget.diaryViewModel.titleController.text = widget.diaryNote.title;
    widget.diaryViewModel.contentController.text = widget.diaryNote.content;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> _formData = {};
    Size size = MediaQuery.of(context).size;
    final _addTitleFormKey = GlobalKey<FormState>();
    final _addContentFormKey = GlobalKey<FormState>();

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
                    top: 200.0,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.bottomLeft,
                        child: StreamBuilder<String>(
                            stream:
                                widget.diaryViewModel.diaryForm.errorTitleText,
                            builder: (context, snapshot) {
                              return TextField(
                                controller:
                                    widget.diaryViewModel.titleController,
                                cursorColor: kPrimaryColor,
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 3.0,
                                        color: Colors.white,
                                      ),
                                    ]),
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration: new InputDecoration(
                                  border: InputBorder.none,
                                ),
                              );
                            })),
                  ),
                  Positioned(
                    top: 300.0,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100.0),
                              topLeft: Radius.circular(100.0)),
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
                child: StreamBuilder<String>(
                    stream: widget.diaryViewModel.diaryForm.errorContentText,
                    builder: (context, snapshot) {
                      return TextField(
                        controller: widget.diaryViewModel.contentController,
                        cursorColor: kPrimaryColor,
                        style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                        ),
                      );
                    }),
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 15.0),
                child: InkResponse(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimaryColor.withOpacity(.5),
                            offset: Offset(1.0, 10.0),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: kPrimaryColor),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 30.0),
                child: InkResponse(
                  onTap: () {
                    widget.diaryViewModel.updatePage(
                        widget.diaryNote.id, widget.diaryNote.isFavourite);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimaryColor.withOpacity(.5),
                            offset: Offset(1.0, 10.0),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Icon(Icons.check, color: kPrimaryColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setOptionsStatus(AnimationStatus status) {
    setState(() {
      _optionsIsOpen = status == AnimationStatus.forward ||
          status == AnimationStatus.completed;
    });
  }

  StreamSubscription<bool> subscribeToSuccessViewModel() {
    return widget.diaryViewModel.isPageAdded.listen((isSuccessfulAdd) {
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
      title: "Page updated!",
      type: AlertType.success,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            routerDelegate.pop();
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
            routerDelegate.pop();
            errorAlert.dismiss();
          },
          color: kPrimaryColor,
        )
      ],
    );
  }

  @override
  void dispose() {
    _optionsAnimationController.dispose();
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
          image: DecorationImage(
              colorFilter:
                  ColorFilter.mode(Color(0xFF3C4858), BlendMode.lighten),
              image: imageProvider,
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}
