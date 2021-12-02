import 'package:flutter/material.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'components/report_details_body.dart';

class ReportDetailsScreen extends StatelessWidget {
  static const route = '/reportDetailsScreen';
  final Report report;

  ReportDetailsScreen({Key key, @required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(report);
    return Scaffold(
      body: ReportDetailsBody(
        report: report,
      ),
    );
  }
}
