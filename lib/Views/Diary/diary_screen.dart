import 'package:dima_colombo_ghiazzi/Views/Diary/components/add_diary_page.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/components/diary_home_page.dart';
import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  static const route = '/diaryScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DiaryHome(),
    );
  }
}
