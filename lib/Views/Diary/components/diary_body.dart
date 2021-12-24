import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/Diary/components/diary_page_data_source.dart';

/// Body of the Diary.
///
/// It contains the [SfCalendar] with the [DiaryPage] provided from the [DiaryPageDataSource]
/// and retrieved from the Firebase DB.
///
/// If today there is not any diary page, it shows the button for adding a new diary page.
class DiaryBody extends StatefulWidget {
  /// Body of the Diary.
  ///
  /// It contains the [SfCalendar] with the [DiaryPage] provided from the [DiaryPageDataSource]
  /// and retrieved from the Firebase DB.
  ///
  /// If today there is not any diary page, it shows the button for adding a new diary page.
  const DiaryBody({Key? key}) : super(key: key);

  _DiaryBodyState createState() => _DiaryBodyState();
}

class _DiaryBodyState extends State<DiaryBody> {
  // View Models
  late DiaryViewModel diaryViewModel;
  late UserViewModel userViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Controller
  final CalendarController _controller = CalendarController();
  CalendarTapDetails? _selectedDayDetails;

  var _loadDiaryPagesStream;

  @override
  void initState() {
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    _loadDiaryPagesStream = diaryViewModel.loadDiaryPages();
    //_selectedDayDetails = CalendarTapDetails(appointments, DateTime.now(), CalendarElement.calendarCell, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _loadDiaryPagesStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              Header(),
              Padding(
                padding: EdgeInsets.only(top: 12.5.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: [
                        // Calendar
                        Expanded(
                          child: SfCalendar(
                            monthCellBuilder: monthCellBuilder,
                            initialSelectedDate: DateTime.now(),
                            controller: _controller,
                            todayHighlightColor: kPrimaryDarkColorTrasparent,
                            dataSource: DiaryPageDataSource(snapshot.data.docs, diaryViewModel),
                            headerStyle: CalendarHeaderStyle(
                              textStyle: TextStyle(color: kPrimaryColor, fontSize: 22.sp, fontWeight: FontWeight.bold),
                            ),
                            headerHeight: 7.5.h,
                            headerDateFormat: " MMM yyyy",
                            showDatePickerButton: true,
                            viewHeaderStyle: ViewHeaderStyle(dayTextStyle: TextStyle(color: kPrimaryColor)),
                            view: CalendarView.month,
                            onTap: (details) => setState(() {
                              _selectedDayDetails = details;
                            }),
                            monthViewSettings: MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.none),
                          ),
                        ),
                        // Agenda
                        Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: kPrimaryDarkColorTrasparent, width: 0.5)),
                            color: kBackgroundColor,
                          ),
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                          height: 14.h,
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10.w,
                                  padding: EdgeInsets.only(top: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat("EEE").format(_selectedDayDetails?.date ?? DateTime.now()).toUpperCase(),
                                        style: TextStyle(color: kPrimaryDarkColorTrasparent, fontSize: 8.sp),
                                      ),
                                      Text(
                                        DateFormat("dd").format(_selectedDayDetails?.date ?? DateTime.now()),
                                        style: TextStyle(color: kPrimaryColor, fontSize: 18.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_selectedDayDetails?.appointments != null && _selectedDayDetails!.appointments!.isNotEmpty) ...[
                                  Expanded(
                                    child: appointmentBuilder(),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 15, top: 5),
                                      child: Text(
                                        "No diary page.",
                                        style: TextStyle(color: kPrimaryGreyColor, fontSize: 13.sp),
                                      ),
                                    ),
                                  ),
                                ],
                                if (!diaryViewModel.hasDiaryPageToday) ...[
                                  // If today there isn't a diary page, show the '+' button
                                  Container(
                                    padding: EdgeInsets.only(left: 10, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FloatingActionButton(
                                          onPressed: () {
                                            // Add a new diary page
                                            diaryViewModel.addNewDiaryPage();
                                            if (MediaQuery.of(context).orientation == Orientation.portrait) {
                                              // If the device orientation is portrait, push the DiaryPageScreen
                                              routerDelegate.pushPage(name: DiaryPageScreen.route);
                                            }
                                          },
                                          materialTapTargetSize: MaterialTapTargetSize.padded,
                                          backgroundColor: kPrimaryColor,
                                          child: const Icon(Icons.add, size: 40.0, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  /// Builder of the agenda appointment.
  ///
  /// It defines the style, the color and the content of the agenda appointment.
  ///
  /// If the specific day has a diary page, it shows the appointment with the proper
  /// color base on if it is a favourite page or not with its title.
  Widget appointmentBuilder() {
    return GestureDetector(
      onTap: () {
        diaryViewModel.setCurrentDiaryPage(_selectedDayDetails!.appointments![0]);
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          routerDelegate.pushPage(name: DiaryPageScreen.route);
        }
      },
      child: Container(
        height: 7.h,
        margin: EdgeInsets.only(left: 10),
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _selectedDayDetails!.appointments?.first.favourite ? kPrimaryGoldenColor : kPrimaryColor,
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                (_selectedDayDetails!.appointments?.first as DiaryPage).title,
                maxLines: 1,
                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builder of the month cell.
  ///
  /// It defines the style, the color and the content of a month cell.
  ///
  /// If the specific day has a diary page, it sets the book icon with the
  /// proper color based on if it is a favourite page or not.
  ///
  /// If the specific day is today, it shows a circle around the number of the day.
  Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
    var mid = details.visibleDates.length ~/ 2.toInt();
    var midDate = details.visibleDates[0].add(Duration(days: mid));
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryDarkColorTrasparent.withOpacity(0.6), width: 0.1),
        color: details.date.month != midDate.month ? kPrimaryLightColor : Colors.transparent,
      ),
      child: Padding(
        padding: Utils.isToday(details.date) && details.date.month == midDate.month ? EdgeInsets.all(0) : EdgeInsets.only(top: 6.0),
        child: Column(
          children: [
            Container(
              width: 22,
              padding: Utils.isToday(details.date) && details.date.month == midDate.month ? EdgeInsets.all(3) : EdgeInsets.all(0),
              margin: Utils.isToday(details.date) && details.date.month == midDate.month ? EdgeInsets.only(top: 3) : EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Utils.isToday(details.date) && details.date.month == midDate.month ? kPrimaryDarkColorTrasparent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                details.date.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: details.date.month == midDate.month
                        ? Utils.isToday(details.date)
                            ? Colors.white
                            : kPrimaryColor
                        : kPrimaryGreyColor,
                    fontSize: 11.sp),
              ),
            ),
            if (details.appointments.isNotEmpty) ...[
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.menu_book,
                    color: (details.appointments.first as DiaryPage).favourite ? kPrimaryGoldenColor : kPrimaryColor, size: 4.h),
              ),
              Spacer(),
            ]
          ],
        ),
      ),
    );
  }
}
