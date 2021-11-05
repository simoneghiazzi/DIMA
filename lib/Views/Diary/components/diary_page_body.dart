import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class DiaryPageBody extends StatefulWidget {
  final DiaryViewModel diaryViewModel;
  final Note diaryNote;

  DiaryPageBody(
      {Key key, @required this.diaryViewModel, @required this.diaryNote})
      : super(key: key);

  @override
  _DiaryPageBodyState createState() => _DiaryPageBodyState();
}

class _DiaryPageBodyState extends State<DiaryPageBody>
    with SingleTickerProviderStateMixin {
  AnimationController _optionsAnimationController;
  Animation<Offset> _optionsAnimation, _optionsDelayedAnimation;

  bool _optionsIsOpen = false;
  @override
  void initState() {
    super.initState();
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
                    top: 200.0,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.bottomLeft,
                        child: Center(
                          child: Text(
                            widget.diaryNote.title,
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
                          ),
                        )),
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
                  child: Text(
                    widget.diaryNote.content,
                    style: TextStyle(color: kPrimaryColor, fontSize: 20),
                  ))
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

  void _openOptions() {
    _optionsAnimationController.forward();
  }

  void _closeOptions() {
    _optionsAnimationController.reverse();
  }

  // TODO: Handle delete action loading state

  /*void _onDeleteClicked(int entryId) {
    showDialog(
      context: context,
      builder: (_) => DiaryConfirmDialog(
        message: "Are you sure you want to delete this?",
        onConfirmed: () => _deleteConfirmed(entryId),
      ),
    );
  }

  void _deleteConfirmed(int entryId) async {
    // Navigator.of(context).pop();
    final response = await Provider.of<EntryViewModel>(context, listen: false)
        .delete(entryId);
    if (response) {
      Navigator.of(context).popAndPushNamed(Home.routeName);
    }
  }*/

  @override
  void dispose() {
    _optionsAnimationController.dispose();
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
