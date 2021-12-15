import 'package:flutter/material.dart';
import 'components/report_details_body.dart';

class ReportDetailsScreen extends StatelessWidget {
  static const route = '/reportDetailsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportDetailsBody(),
    );
  }
}
