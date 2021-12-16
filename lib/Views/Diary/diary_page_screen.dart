import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';

class DiaryPageScreen extends StatelessWidget {
  static const route = '/diaryPageScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: DiaryPageBody(),
    );
  }
}
