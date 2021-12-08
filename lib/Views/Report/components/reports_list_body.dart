import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Report/report_details_screen.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ReportsListBody extends StatefulWidget {
  final ReportViewModel reportViewModel;

  ReportsListBody({Key key, @required this.reportViewModel}) : super(key: key);

  @override
  _ReportsListBodyState createState() => _ReportsListBodyState();
}

class _ReportsListBodyState extends State<ReportsListBody> {
  final ScrollController listScrollController = ScrollController();
  AppRouterDelegate routerDelegate;
  Alert alert;
  bool isLoading = false;
  int _limitIncrement = 20;

  @override
  void initState() {
    listScrollController.addListener(scrollListener);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TopBar(
          text: 'Old reports',
        ),
        Flexible(
          child: StreamBuilder(
            stream: widget.reportViewModel.loadReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                );
              } else
                return LoadingDialog().widget(context);
            },
          ),
        ),
      ],
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot doc) {
    // This size provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    if (doc != null) {
      Report report = new Report();
      report.setFromDocument(doc);
      String date = DateFormat('yyyy-MM-dd kk:mm').format(report.date);
      return Container(
        child: TextButton(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 25.0,
                  child: Image.asset(
                    "assets/icons/logo.png",
                    height: size.height * 0.05,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  report.category,
                  style: TextStyle(color: kPrimaryColor, fontSize: 18),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(date.split(' ')[0], style: TextStyle(color: kPrimaryColor, fontSize: 10)),
                Text(date.split(' ')[1].split('.')[0].split(':')[0] + ":" + date.split(' ')[1].split('.')[0].split(':')[1],
                    style: TextStyle(color: kPrimaryColor, fontSize: 10))
              ],
            )
          ]),
          onPressed: () {
            widget.reportViewModel.openReport(report);
            if (MediaQuery.of(context).orientation != Orientation.landscape) {
              routerDelegate.pushPage(
                name: ReportDetailsScreen.route,
                arguments: ReportDetailsArguments(widget.reportViewModel.openedReport, widget.reportViewModel),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryLightColor),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limitIncrement += _limitIncrement;
      });
    }
  }
}
