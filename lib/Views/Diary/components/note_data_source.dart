import 'dart:collection';

import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class NoteDataSource extends CalendarDataSource {
  DiaryViewModel diaryViewModel;
  HashSet setIds = new HashSet();

  NoteDataSource(List<Note> source, DiaryViewModel diaryViewModel) {
    this.diaryViewModel = diaryViewModel;
    for (Note n in source) {
      setIds.add(n.id);
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
    return "PAGE";
  }

  @override
  Color getColor(int index) {
    return Color(0xffbd8e80);
  }

  @override
  bool isAllDay(int index) {
    return true;
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    var results = await diaryViewModel.loadPages(startDate, endDate);
    List<Note> newNotes = [];
    for (Note n in results) {
      if (setIds.add(n.id)) {
        newNotes.add(n);
      }
    }
    appointments.addAll(newNotes);
    notifyListeners(CalendarDataSourceAction.add, newNotes);
  }
}
