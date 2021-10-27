import 'package:dima_colombo_ghiazzi/Views/Diary/components/add_diary_page.dart';
import 'package:flutter/material.dart';

class AddPageScreen extends StatelessWidget {
  static const route = '/diaryScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddEntry(),
    );
  }
}
