import 'package:intl/intl.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportDetailsBody extends StatefulWidget {
  final Report report;

  ReportDetailsBody({Key key, @required this.report}) : super(key: key);

  @override
  _ReportDetailsBodyState createState() => _ReportDetailsBodyState();
}

class _ReportDetailsBodyState extends State<ReportDetailsBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              text: widget.report.category,
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -5.0, 0.0),
              height: size.height / 10,
              color: kPrimaryColor,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: size.height / 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(widget.report.date),
                          style: TextStyle(
                            color: kPrimaryColor.withAlpha(150),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
                    child: Text(
                      "Description:",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20),
                    child: Text(
                      widget.report.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
