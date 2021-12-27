import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Views/Diary/components/diary_page_body.dart';

/// Page that shows the [DiaryPage].
///
/// It contains the [DiaryPageBody] with the title and the content of the note
/// and the controllers for modifing and setting it as favourite or not.
class DiaryPageScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/diaryPageScreen";

  /// Page that shows the [DiaryPage].
  ///
  /// It contains the [DiaryPageBody] with the title and the content of the note
  /// and the controllers for modifing and setting it as favourite or not.
  const DiaryPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: DiaryPageBody(),
    );
  }
}
