import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';

/// Constructor of the report list.
///
/// It contains the [TopBar] and the [ListView] that builds the list of report provided
/// by the [ReportViewModel] and retrieved from the Firebase DB.
class ReportListBody extends StatefulWidget {
  /// Constructor of the report list.
  ///
  /// It contains the [TopBar] and the [ListView] that builds the list of report provided
  /// by the [ReportViewModel] and retrieved from the Firebase DB.
  const ReportListBody({Key? key}) : super(key: key);

  @override
  _ReportListBodyState createState() => _ReportListBodyState();
}

class _ReportListBodyState extends State<ReportListBody> {
  // View Models
  late ReportViewModel reportViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TopBar(text: "Old reports"),
        Flexible(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              Report _reportItem = reportViewModel.reports.values.elementAt(reportViewModel.reports.length - 1 - index);
              String date = DateFormat("yyyy-MM-dd kk:mm").format(_reportItem.dateTime!);
              return Container(
                margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
                child: TextButton(
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(backgroundColor: Colors.transparent, radius: 25.0, child: Image.asset("assets/icons/logo.png", scale: 12)),
                      SizedBox(width: 1.5.w),
                      // Title
                      Text(
                        _reportItem.category,
                        style: TextStyle(color: kPrimaryColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      // DateTime
                      Spacer(),
                      Column(
                        children: <Widget>[
                          Text(date.split(" ")[0], style: TextStyle(color: kPrimaryColor, fontSize: 8.5.sp)),
                          Text(
                            date.split(" ")[1].split(".")[0].split(":")[0] + ":" + date.split(" ")[1].split(".")[0].split(":")[1],
                            style: TextStyle(color: kPrimaryColor, fontSize: 8.5.sp),
                          )
                        ],
                      )
                    ],
                  ),
                  onPressed: () {
                    reportViewModel.setCurrentReport(_reportItem);
                    if (MediaQuery.of(context).orientation == Orientation.portrait) {
                      routerDelegate.pushPage(name: ReportDetailsScreen.route);
                    } else {
                      setState(() {});
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        _reportItem == reportViewModel.currentReport.value ? kPrimaryButtonColor : kPrimaryLightColor),
                    shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25)))),
                  ),
                ),
              );
            },
            itemCount: reportViewModel.reports.length,
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }
}
