import 'package:provider/provider.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Report/components/report_details_body.dart';
import 'package:sApport/Views/Report/components/reports_list_body.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:split_view/split_view.dart';

import '../../constants.dart';

class ReportsListScreen extends StatefulWidget {
  static const route = '/reportListScreen';

  ReportsListScreen({Key key}) : super(key: key);

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? ReportsListBody()
          : SplitView(
              controller: SplitViewController(weights: [0.35, 0.65]),
              children: [
                ReportsListBody(),
                reportViewModel.currentReport == null ? EmptyLandscapeBody() : ReportDetailsBody(),
              ],
              viewMode: SplitViewMode.Horizontal,
              gripSize: 0.3,
              gripColor: kPrimaryGreyColor,
            ),
    );
  }
}
