import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Diary/components/note_data_source.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DiaryBody extends StatefulWidget {
  const DiaryBody({Key key}) : super(key: key);

  _DiaryBodyState createState() => _DiaryBodyState();
}

class _DiaryBodyState extends State<DiaryBody> {
  DiaryViewModel diaryViewModel;
  UserViewModel userViewModel;
  AppRouterDelegate routerDelegate;
  final CalendarController _controller = CalendarController();

  var _loadDiaryPagesStream;

  @override
  void initState() {
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    _loadDiaryPagesStream = diaryViewModel.loadDiaryPages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: _loadDiaryPagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Header(),
                    Container(
                      transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                      height: size.height / 2,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: size.height / 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(color: kPrimaryColor.withOpacity(.5), blurRadius: 10.0),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
                    child: SfCalendar(
                      initialSelectedDate: DateTime.now(),
                      controller: _controller,
                      todayHighlightColor: kPrimaryColor,
                      dataSource: NoteDataSource(snapshot.data.docs, diaryViewModel),
                      headerStyle: CalendarHeaderStyle(
                        textStyle: TextStyle(color: kPrimaryColor, fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      headerHeight: 50,
                      headerDateFormat: " MMM yyyy",
                      cellBorderColor: kPrimaryDarkColorTrasparent.withOpacity(0.5),
                      showDatePickerButton: true,
                      viewHeaderStyle: ViewHeaderStyle(
                        dayTextStyle: TextStyle(color: kPrimaryColor),
                        dateTextStyle: TextStyle(color: kPrimaryColor),
                      ),
                      view: CalendarView.month,
                      monthViewSettings: MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                        appointmentDisplayCount: 1,
                        showAgenda: true,
                        agendaViewHeight: diaryViewModel.hasNoteToday ? size.height / 10 : size.height / 8,
                        agendaItemHeight: size.height / 15,
                        monthCellStyle: MonthCellStyle(
                          trailingDatesBackgroundColor: kPrimaryLightColor,
                          leadingDatesBackgroundColor: kPrimaryLightColor,
                          textStyle: TextStyle(color: kPrimaryColor),
                        ),
                      ),
                      onTap: showDetails,
                    ),
                  ),
                ),
              ),
              !diaryViewModel.hasNoteToday
                  ? Align(
                      alignment: Alignment.lerp(
                          Alignment.lerp(Alignment.lerp(Alignment.bottomRight, Alignment.topRight, 0.005), Alignment.center, 0.05),
                          Alignment.bottomLeft,
                          0.02),
                      child: FloatingActionButton(
                        onPressed: () {
                          diaryViewModel.setCurrentDiaryPage(DiaryPage());
                          if (MediaQuery.of(context).orientation == Orientation.portrait) {
                            routerDelegate.pushPage(name: DiaryPageScreen.route);
                          }
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
          );
        }
        return Container();
      },
    );
  }

  void showDetails(CalendarTapDetails details) {
    if (details.appointments != null) {
      if (details.appointments.isNotEmpty && details.targetElement == CalendarElement.appointment) {
        diaryViewModel.setCurrentDiaryPage(details.appointments[0]);
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          routerDelegate.pushPage(name: DiaryPageScreen.route);
        }
      }
    }
  }
}
