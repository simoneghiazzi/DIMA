import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/reports_list_body.dart';
import 'package:flutter/material.dart';

class ReportsListScreen extends StatelessWidget {
  final ReportViewModel reportViewModel;

  ReportsListScreen({Key key, @required this.reportViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReportsListBody(
        reportViewModel: reportViewModel,
      ),
    );
  }
}
