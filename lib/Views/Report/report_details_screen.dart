import 'package:flutter/material.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'components/report_details_body.dart';

class ReportDetailsScreen extends StatelessWidget {
  static const route = '/reportDetailsScreen';
  final bool startOrientation;
  final ReportViewModel reportViewModel;

  ReportDetailsScreen({Key key, this.startOrientation = false, @required this.reportViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportDetailsBody(
        startOrientation: startOrientation,
        reportViewModel: reportViewModel,
      ),
    );
  }
}
