import 'package:sApport/Model/BaseUser/Diary/note.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class DiaryPageScreen extends StatelessWidget {
  static const route = '/diaryPageScreen';
  final Note diaryNote;

  DiaryPageScreen({Key key, this.diaryNote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: DiaryPageBody(
        diaryNote: diaryNote,
      ),
    );
  }
}
