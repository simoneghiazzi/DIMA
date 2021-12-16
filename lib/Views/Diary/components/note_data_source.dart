import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class NoteDataSource extends CalendarDataSource {
  NoteDataSource(List<DocumentSnapshot> docs, DiaryViewModel diaryViewModel) {
    var today = DateTime.now();
    List<DiaryPage> source = List.from([]);
    for (DocumentSnapshot doc in docs) {
      DiaryPage n = DiaryPage.fromDocument(doc);
      source.add(n);
      if (n.dateTime.day == today.day && n.dateTime.month == today.month && n.dateTime.year == today.year) {
        diaryViewModel.hasNoteToday = true;
      } else {
        diaryViewModel.hasNoteToday = false;
      }
    }
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    DateTime date = appointments[index].dateTime;
    return DateTime(date.year, date.month, date.day);
  }

  @override
  DateTime getEndTime(int index) {
    DateTime date = appointments[index].dateTime;
    return DateTime(date.year, date.month, date.day);
  }

  @override
  String getSubject(int index) {
    return appointments[index].title;
  }

  @override
  Color getColor(int index) {
    if (appointments[index].favourite) {
      return kPrimaryGoldenColor;
    }
    return kPrimaryColor;
  }

  @override
  bool isAllDay(int index) {
    return true;
  }
}
