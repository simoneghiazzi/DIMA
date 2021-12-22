import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
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
import 'package:sizer/sizer.dart';

class ReportsListBody extends StatefulWidget {
  @override
  _ReportsListBodyState createState() => _ReportsListBodyState();
}

class _ReportsListBodyState extends State<ReportsListBody> {
  late ReportViewModel reportViewModel;
  late AppRouterDelegate routerDelegate;
  late Alert alert;
  bool isLoading = false;

  var _loadReportsStream;

  @override
  void initState() {
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    _loadReportsStream = reportViewModel.loadReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TopBar(back: reportViewModel.resetCurrentReport, text: "Old reports"),
        Flexible(
          child: StreamBuilder(
            stream: _loadReportsStream,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                );
              } else
                return CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? doc) {
    if (doc != null) {
      Report report = Report.fromDocument(doc);
      String date = DateFormat('yyyy-MM-dd kk:mm').format(report.dateTime!);
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
                    height: 5.h,
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
            reportViewModel.setCurrentReport(report);
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              routerDelegate.pushPage(name: ReportDetailsScreen.route);
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

  Alert createAlert(String title, String description) {
    return Alert(
        context: context,
        title: title,
        desc: description,
        image: Image.asset("assets/icons/small_logo.png"),
        closeIcon: Icon(
          Icons.close,
          color: kPrimaryColor,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "CLOSE",
              style: TextStyle(color: kPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            color: Colors.transparent,
            onPressed: () => alert.dismiss(),
          )
        ]);
  }
}
