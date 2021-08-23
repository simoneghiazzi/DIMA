import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/grid.dart';

class HomeBody extends StatelessWidget {
  final AuthViewModel authViewModel;

  HomeBody({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Header(
            authViewModel: authViewModel,
          ),
          SizedBox(height: size.height * 0.1),
          Grid(
            authViewModel: authViewModel,
          ),
        ],
      ),
    );
  }
}
