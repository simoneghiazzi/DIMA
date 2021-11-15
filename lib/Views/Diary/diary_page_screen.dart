import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/components/diary_page_body.dart';
import 'package:flutter/material.dart';

class DiaryPageScreen extends StatelessWidget {
  static const route = '/diaryPageScreen';
  final Note diaryNote;

  DiaryPageScreen({Key key, this.diaryNote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DiaryPageBody(
        diaryNote: diaryNote,
      ),
    );
  }
}
