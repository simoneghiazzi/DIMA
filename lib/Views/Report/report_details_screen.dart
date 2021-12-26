import 'package:flutter/material.dart';
import 'components/report_details_body.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';

/// Page that shows the [Report].
///
/// It contains the [ReportDetailsBody] with the category and the description
/// of the report.
class ReportDetailsScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/reportDetailsScreen";

  /// Page that shows the [Report].
  ///
  /// It contains the [ReportDetailsBody] with the category and the description
  /// of the report.
  const ReportDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportDetailsBody(),
    );
  }
}
