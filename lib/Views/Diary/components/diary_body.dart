import 'package:flutter_form_bloc/flutter_form_bloc.dart';
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
import 'package:sApport/Model/BaseUser/Diary/diary_page.dart';

class DiaryBody extends StatefulWidget {
  final DiaryViewModel diaryViewModel;

  const DiaryBody({Key key, @required this.diaryViewModel}) : super(key: key);

  _DiaryBodyState createState() => _DiaryBodyState();
}

class _DiaryBodyState extends State<DiaryBody> {
  UserViewModel userViewModel;
  AppRouterDelegate routerDelegate;
  final CalendarController _controller = CalendarController();
  String _headerText;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    _headerText = "header";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: widget.diaryViewModel.loadDiaryPages(),
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
                      controller: _controller,
                      todayHighlightColor: kPrimaryColor,
                      dataSource: NoteDataSource(snapshot.data.docs, widget.diaryViewModel),
                      headerStyle: CalendarHeaderStyle(
                        textStyle: TextStyle(color: kPrimaryColor, fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      headerHeight: 50,
                      headerDateFormat: " MMM yyyy",
                      cellBorderColor: kPrimaryColor,
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
                          agendaViewHeight: widget.diaryViewModel.hasNoteToday ? size.height / 10 : size.height / 8,
                          agendaItemHeight: size.height / 15,
                          monthCellStyle: MonthCellStyle(
                            trailingDatesBackgroundColor: kPrimaryLightColor,
                            leadingDatesBackgroundColor: kPrimaryLightColor,
                          )),
                      onViewChanged: (ViewChangedDetails viewChangedDetails) {
                        if (_controller.view == CalendarView.month) {
                          _headerText =
                              DateFormat('MMM yyyy').format(viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length ~/ 2]).toString();
                        }
                      },
                      onTap: showDetails,
                    ),
                  ),
                ),
              ),
              !widget.diaryViewModel.hasNoteToday
                  ? Align(
                      alignment: Alignment.lerp(
                          Alignment.lerp(Alignment.lerp(Alignment.bottomRight, Alignment.topRight, 0.005), Alignment.center, 0.05),
                          Alignment.bottomLeft,
                          0.02),
                      child: FloatingActionButton(
                        onPressed: () {
                          //widget.diaryViewModel.openPage(null);
                          if (MediaQuery.of(context).orientation != Orientation.landscape) {
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
        final DiaryPage noteDetails = details.appointments[0];
        //widget.diaryViewModel.openPage(noteDetails);
        if (MediaQuery.of(context).orientation != Orientation.landscape) {
          routerDelegate.pushPage(name: DiaryPageScreen.route, arguments: widget.diaryViewModel);
        }
      }
    }
  }
}
