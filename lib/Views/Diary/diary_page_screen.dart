import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/components/diary_page_body.dart';
import 'package:flutter/material.dart';

class DiaryPageScreen extends StatelessWidget {
  static const route = '/diaryPageScreen';
  final DiaryViewModel diaryViewModel;

  DiaryPageScreen({Key key, @required this.diaryViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DiaryPageBody(
        diaryViewModel: diaryViewModel,
      ),
    );
  }
}
