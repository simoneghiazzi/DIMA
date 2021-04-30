import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/grid.dart';

class HomeBody extends StatelessWidget {

  final AuthViewModel authViewModel;

  HomeBody({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Header(authViewModel: authViewModel,),
          Grid(),
        ],
      ),
    );
  }
}
