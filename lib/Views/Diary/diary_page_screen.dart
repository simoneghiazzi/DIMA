import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class DiaryPageScreen extends StatelessWidget {
  static const route = '/diaryPageScreen';
  final DiaryViewModel diaryViewModel;
  bool startOrientation;

  DiaryPageScreen({Key key, @required this.diaryViewModel, this.startOrientation = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: DiaryPageBody(
        diaryViewModel: diaryViewModel,
      ),
    );
  }
}
