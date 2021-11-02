import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DiaryHome extends StatefulWidget {
  _DiaryHomeState createState() => _DiaryHomeState();
}

class _DiaryHomeState extends State<DiaryHome> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SfCalendar(
      dataSource: MeetingDataSource(_getDataSource()),
      headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(color: kPrimaryColor, fontSize: 25)),
      cellBorderColor: kPrimaryColor,
      view: CalendarView.month,
      monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    ));
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting('Oggi mi sento molto bene finalmente!', startTime,
        endTime, const Color(0xFF0F8644), false, 'asada'));
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay,
      this.id);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String id;
  Function onTap() {
    print("CIAO!!!");
  }
}
