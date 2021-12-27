import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

/// Body of the [ReportDetailsScreen].
///
/// It contains all the details of the [Report] : the category, the description
/// and the datetime of submission.
class ReportDetailsBody extends StatefulWidget {
  /// Body of the [ReportDetailsScreen].
  ///
  /// It contains all the details of the [Report] : the category, the description
  /// and the datetime of submission.
  const ReportDetailsBody({Key? key}) : super(key: key);

  @override
  _ReportDetailsBodyState createState() => _ReportDetailsBodyState();
}

class _ReportDetailsBodyState extends State<ReportDetailsBody> with WidgetsBindingObserver {
  // View Models
  late ReportViewModel reportViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);

    // Add a back button interceptor for listening to the OS back button
    BackButtonInterceptor.add(backButtonInterceptor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Category
        TopBar(
          onBack: reportViewModel.resetCurrentReport,
          text: reportViewModel.currentReport.value!.category,
          textSize: 17.sp,
          backIcon: Icons.close,
          back: MediaQuery.of(context).orientation == Orientation.portrait,
        ),
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(color: kPrimaryColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    // DateTime
                    Text(
                      DateFormat("dd MMM yyyy").format(reportViewModel.currentReport.value!.dateTime!),
                      style: TextStyle(color: kPrimaryColor.withAlpha(150), fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(color: kPrimaryDarkColorTrasparent, height: 30, thickness: 0.2),
                // Description
                Text(
                  reportViewModel.currentReport.value!.description,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: kPrimaryColor, fontSize: 15.5.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Function called by the back button interceptor.
  ///
  /// It resets the current report of the [ReportViewModel] and then pop the page.
  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    reportViewModel.resetCurrentReport();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
