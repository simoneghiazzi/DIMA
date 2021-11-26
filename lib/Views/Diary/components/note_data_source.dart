import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/BaseUser/Diary/note.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class NoteDataSource extends CalendarDataSource {
  DiaryViewModel diaryViewModel;

  NoteDataSource(List<DocumentSnapshot> docs, DiaryViewModel diaryViewModel) {
    this.diaryViewModel = diaryViewModel;
    var today = DateTime.now();
    List<Note> source = List.from([]);
    for (DocumentSnapshot doc in docs) {
      Note n = Note();
      n.setFromDocument(doc);
      source.add(n);
      if (n.date == DateTime(today.year, today.month, today.day)) {
        diaryViewModel.hasNoteToday = true;
      }
    }
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    DateTime date = appointments[index].date;
    return DateTime(date.year, date.month, date.day);
  }

  @override
  DateTime getEndTime(int index) {
    DateTime date = appointments[index].date;
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
    return kPrimaryMediumColor;
  }

  @override
  bool isAllDay(int index) {
    return true;
  }
}
