import 'package:flutter/material.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Views/Report/components/create_report_body.dart';

/// Page for the creation of a new [Report].
///
/// It contains the [CreateReportBody] with the [ReportForm] that is used
/// for creating and submitting to the Firebase DB the new report.
class CreateReportScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/createReportScreen";

  /// Page for the creation of a new [Report].
  ///
  /// It contains the [CreateReportBody] with the [ReportForm] that is used
  /// for creating and submitting to the Firebase DB the new report.
  const CreateReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateReportBody(),
    );
  }
}
