import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/components/note_data_source.dart';
import 'package:dima_colombo_ghiazzi/Views/Diary/diary_page_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/Diary/note.dart';

class DiaryBody extends StatefulWidget {
  _DiaryBodyState createState() => _DiaryBodyState();
}

class _DiaryBodyState extends State<DiaryBody> {
  DiaryViewModel diaryViewModel;
  BaseUserViewModel baseUserViewModel;
  AppRouterDelegate routerDelegate;
  DateTime startDate, endDate;

  @override
  void initState() {
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    var now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate =
        DateTime(now.year, now.month, DateTime(now.year, now.month + 1, 0).day);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: FutureBuilder(
      future: diaryViewModel.loadPages(startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              body: Stack(
            children: <Widget>[
              SfCalendar(
                onViewChanged: viewChanged,
                todayHighlightColor: kPrimaryColor,
                dataSource: NoteDataSource(snapshot.data, diaryViewModel),
                headerStyle: CalendarHeaderStyle(
                    textStyle: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                headerHeight: size.height / 10,
                cellBorderColor: kPrimaryColor,
                view: CalendarView.month,
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment,
                    appointmentDisplayCount: 1,
                    showAgenda: true,
                    agendaViewHeight: size.height / 8,
                    agendaItemHeight: size.height / 15,
                    monthCellStyle: MonthCellStyle(
                      trailingDatesBackgroundColor: kPrimaryLightColor,
                      leadingDatesBackgroundColor: kPrimaryLightColor,
                    )),
                loadMoreWidgetBuilder: loadMoreWidget,
                onTap: showDetails,
              ),
              !diaryViewModel.hasNoteToday
                  ? Align(
                      alignment: Alignment.lerp(
                          Alignment.bottomRight, Alignment.center, 0.1),
                      child: FloatingActionButton(
                        onPressed: () {
                          routerDelegate.pushPage(name: DiaryPageScreen.route);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        backgroundColor: kPrimaryColor,
                        child: const Icon(
                          Icons.add,
                          size: 40.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ));
        }
        return Container();
      },
    ));
  }

  void showDetails(CalendarTapDetails details) {
    if (details.appointments != null) {
      if (details.appointments.isNotEmpty &&
          details.targetElement == CalendarElement.appointment) {
        final Note noteDetails = details.appointments[0];
        routerDelegate.pushPage(
            name: DiaryPageScreen.route, arguments: noteDetails);
      }
    }
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    startDate = viewChangedDetails.visibleDates[0];
    endDate = viewChangedDetails
        .visibleDates[viewChangedDetails.visibleDates.length - 1];
  }

  Widget loadMoreWidget(
      BuildContext context, LoadMoreCallback loadMoreAppointments) {
    return FutureBuilder<void>(
      initialData: 'loading',
      future: loadMoreAppointments(),
      builder: (context, snapShot) {
        return Container(
            alignment: Alignment.center, child: CircularProgressIndicator());
      },
    );
  }
}
