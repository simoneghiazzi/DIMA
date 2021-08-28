import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/create_report_body.dart';

class CreateReportScreen extends StatelessWidget {
  final BaseUserViewModel baseUserViewModel;

  CreateReportScreen({Key key, @required this.baseUserViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateReportBody(
        baseUserViewModel: baseUserViewModel,
      ),
    );
  }
}
