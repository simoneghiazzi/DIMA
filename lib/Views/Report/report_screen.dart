import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/body.dart';

class ReportScreen extends StatelessWidget {
  final AuthViewModel authViewModel;

  ReportScreen({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        authViewModel: authViewModel,
      ),
    );
  }
}
