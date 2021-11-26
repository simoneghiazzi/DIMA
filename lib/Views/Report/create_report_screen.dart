import 'package:flutter/material.dart';
import 'package:sApport/Views/Report/components/create_report_body.dart';

class CreateReportScreen extends StatelessWidget {
  static const route = '/createReportScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateReportBody(),
    );
  }
}
