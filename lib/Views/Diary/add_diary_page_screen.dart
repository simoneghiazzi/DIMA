import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/components/add_diary_page_body.dart';
import 'package:flutter/material.dart';

class AddDiaryPageScreen extends StatelessWidget {
  static const route = '/addDiaryPageScreen';
  final DiaryViewModel diaryViewModel;

  AddDiaryPageScreen({Key key, @required this.diaryViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddDiaryPageBody(diaryViewModel: diaryViewModel),
    );
  }
}
