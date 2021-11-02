import 'package:dima_colombo_ghiazzi/Views/Diary/components/diary_body.dart';
import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  static const route = '/diaryScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DiaryBody(),
    );
  }
}
