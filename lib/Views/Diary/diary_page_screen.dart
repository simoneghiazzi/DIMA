import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/BaseUser/Diary/diary_page.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';

class DiaryPageScreen extends StatelessWidget {
  static const route = '/diaryPageScreen';
  final DiaryPage diaryPage;

  /// Screen of the diary page details
  DiaryPageScreen({Key key, @required this.diaryPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: DiaryPageBody(diaryPage: diaryPage),
    );
  }
}
