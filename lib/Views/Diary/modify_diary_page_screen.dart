import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:flutter/material.dart';
import 'components/modify_diary_page_body.dart';

class ModifyDiaryPageScreen extends StatelessWidget {
  static const route = '/addDiaryPageScreen';
  final DiaryViewModel diaryViewModel;
  final Note diaryNote;

  ModifyDiaryPageScreen(
      {Key key, @required this.diaryViewModel, @required this.diaryNote})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModifyDiaryPageBody(
        diaryViewModel: diaryViewModel,
        diaryNote: diaryNote,
      ),
    );
  }
}
