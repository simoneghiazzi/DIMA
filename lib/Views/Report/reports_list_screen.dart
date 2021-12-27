import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/components/empty_landscape_body.dart';
import 'package:sApport/Views/Report/components/report_list_body.dart';
import 'package:sApport/Views/Report/components/report_details_body.dart';

/// Page of the report list of the user.
///
/// It contains the [OrientationBuilder] that checks the orientation of the device and
/// rebuilds the page when the orientation changes. If it is:
/// - portrait: it displays the [ReportListBody].
/// - landscape: it uses the [VerticalSplitView] for displayng the [ReportListBody] on the left and the
/// [ReportDetailsBody] (if one report is selected) on the right.
///
/// It subscribes to the report view model currentReport value notifier in order to rebuild the
/// right hand side of the page when a new current report is selected.
/// If the current report is null, it shows the [EmptyLandscapeBody].
class ReportsListScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/reportListScreen";

  /// Page of the report list of the user.
  ///
  /// It contains the [OrientationBuilder] that checks the orientation of the device and
  /// rebuilds the page when the orientation changes. If it is:
  /// - portrait: it displays the [ReportListBody].
  /// - landscape: it uses the [VerticalSplitView] for displayng the [ReportListBody] on the left and the
  /// [ReportDetailsBody] (if one report is selected) on the right.
  ///
  /// It subscribes to the report view model currentReport value notifier in order to rebuild the
  /// right hand side of the page when a new current report is selected.
  /// If the current report is null, it shows the [EmptyLandscapeBody].
  const ReportsListScreen({Key? key}) : super(key: key);

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  // View Models
  late ReportViewModel reportViewModel;

  @override
  void initState() {
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            // If the orientation is protrait, shows the ReportListBody
            return ReportListBody();
          } else {
            // If the orientation is landscape, shows the VerticalSplitView with the ReportListBody
            // on the left and the ValueListenableBuilder listener on the right that builds the
            // ChatPageBody or the EmptyLandscapeBody depending on the value of the currentChat
            return VerticalSplitView(
              left: ReportListBody(),
              right: ValueListenableBuilder(
                valueListenable: reportViewModel.currentReport,
                builder: (context, Report? report, child) {
                  // Check if the current chat is null
                  if (report != null) {
                    return ReportDetailsBody(key: ValueKey(report.id));
                  } else {
                    return EmptyLandscapeBody();
                  }
                },
              ),
              ratio: 0.35,
              dividerWidth: 0.3,
              dividerColor: kPrimaryGreyColor,
            );
          }
        },
      ),
    );
  }
}
