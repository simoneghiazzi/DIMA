import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/Report/reports_list_screen.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';

class ReportDetailsBody extends StatefulWidget {
  final Report report;

  ReportDetailsBody({Key key, @required this.report}) : super(key: key);

  @override
  _ReportDetailsBodyState createState() => _ReportDetailsBodyState();
}

class _ReportDetailsBodyState extends State<ReportDetailsBody> {
  ReportViewModel reportViewModel;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //detectChangeOrientation();
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              text: widget.report.category,
              isPortrait: MediaQuery.of(context).orientation == Orientation.landscape,
            ),
            MediaQuery.of(context).orientation == Orientation.landscape
                ? Container()
                : Container(
                    transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                    height: size.height / 10,
                    color: kPrimaryColor,
                  ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: size.height / 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(widget.report.date),
                          style: TextStyle(
                            color: kPrimaryColor.withAlpha(150),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
                    child: Text(
                      "Description:",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20),
                    child: Text(
                      widget.report.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
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

  // Future<void> detectChangeOrientation() async {
  //   if (widget.startOrientation != (MediaQuery.of(context).orientation == Orientation.landscape)) {
  //     widget.startOrientation = true;
  //     await Future(() async {
  //       routerDelegate.replaceAllButNumber(3, [
  //         RouteSettings(
  //             name: ReportsListScreen.route,
  //             arguments:
  //                 ReportArguments(ReportDetailsScreen(startOrientation: true, reportViewModel: widget.reportViewModel), widget.reportViewModel))
  //       ]);
  //     });
  //   }
  // }

}
