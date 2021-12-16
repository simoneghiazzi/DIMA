import 'package:sApport/Views/Home/components/header.dart';
import 'package:flutter/cupertino.dart';
import 'background.dart';
import 'base_user_grid.dart';

class BaseUserHomePageBody extends StatefulWidget {
  const BaseUserHomePageBody({Key key}) : super(key: key);
  @override
  _BaseUserHomePageBodyState createState() => _BaseUserHomePageBodyState();
}

class _BaseUserHomePageBodyState extends State<BaseUserHomePageBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Header(),
          Expanded(
            child: Background(
              child: Column(
                children: [Spacer(), BaseUserGrid(), Spacer()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
