import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Report/components/reports_list_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/components/empty_portrait_body.dart';
import 'package:split_view/split_view.dart';

import '../../constants.dart';

class ReportsListScreen extends StatefulWidget {
  static const route = '/reportListScreen';

  ReportsListScreen({Key key}) : super(key: key);

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  bool isReportOpen = false;

  @override
  Widget build(BuildContext context) {
    //detectChangeOrientation();
    //widget.reportViewModel.checkOpenReport();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:
          // MediaQuery.of(context).orientation == Orientation.landscape
          //     ? SplitView(
          //         controller: SplitViewController(weights: [0.4, 0.6]),
          //         children: [
          //           ReportsListBody(
          //             reportViewModel: widget.reportViewModel,
          //           ),
          //           StreamBuilder(
          //               stream: widget.reportViewModel.isReportOpen,
          //               builder: (context, snapshot) {
          //                 if (snapshot.data == true) {
          //                   isReportOpen = true;
          //                   return ReportDetailsScreen(
          //                     startOrientation: MediaQuery.of(context).orientation == Orientation.landscape,
          //                     reportViewModel: widget.reportViewModel,
          //                   );
          //                 }
          //                 return EmptyPagePortrait();
          //               })
          //         ],
          //         viewMode: SplitViewMode.Horizontal,
          // gripSize: 0.3,
          // gripColor: kPrimaryGreyColor,
          //       )
          //     :
          ReportsListBody(),
    );
  }

  // Future<void> detectChangeOrientation() async {
  //   AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
  //   await Future(() async {
  //     if ((MediaQuery.of(context).orientation == Orientation.portrait) && isReportOpen) {
  //       routerDelegate.pushPage(
  //         name: ReportDetailsScreen.route,
  //         arguments: ReportDetailsArguments(widget.reportViewModel.openedReport, widget.reportViewModel),
  //       );
  //     }
  //   });
  // }
}
