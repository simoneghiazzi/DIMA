import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ReportListPage extends StatefulWidget {
  final ReportViewModel reportViewModel;

  ReportListPage({Key key, @required this.reportViewModel}) : super(key: key);

  @override
  _BodyState createState() => _BodyState(reportViewModel: reportViewModel);
}

class _BodyState extends State<ReportListPage> {
  _BodyState({@required this.reportViewModel});

  final ReportViewModel reportViewModel;
  final ScrollController listScrollController = ScrollController();
  bool isLoading = false;
  int _limitIncrement = 20;

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          splashColor: Colors.grey,
                          icon: Icon(
                            Icons.arrow_back,
                            color: kPrimaryColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          "Reports list",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor),
                        )
                      ],
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: kPrimaryLightColor,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: kPrimaryColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Add New",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: StreamBuilder(
                stream: reportViewModel.loadReports(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(context, snapshot.data?.docs[index]),
                      itemCount: snapshot.data.docs.length,
                      controller: listScrollController,
                      shrinkWrap: true,
                    );
                  } else {
                    return LoadingDialog(text: 'Loading reports...');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot doc) {
    // This size provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    String date = DateFormat('yyyy-MM-dd kk:mm').format(doc.get('date').toDate());
    if (doc != null) {
      return Container(
        child: TextButton(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 30.0,
                      child: Image.asset(
                        "assets/icons/logo.png",
                        height: size.height * 0.05,
                      ),
                    ),
                    Text(doc.get('category'),
                        style: TextStyle(color: kPrimaryColor, fontSize: 20)),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(date.split(' ')[0],
                        style: TextStyle(color: kPrimaryColor)),
                    Text(
                        date.split(' ')[1].split('.')[0].split(':')[0] +
                            ":" +
                            date.split(' ')[1].split('.')[0].split(':')[1],
                        style: TextStyle(color: kPrimaryColor))
                  ],
                )
              ]),
          onPressed: () {
            _onReportPressed(
                context, doc.get('category'), doc.get('description'));
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(kPrimaryLightColor),
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
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limitIncrement += _limitIncrement;
      });
    }
  }

  _onReportPressed(context, String title, String description) {
    Alert(
        context: context,
        title: title.toUpperCase(),
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
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: kPrimaryColor,
            onPressed: () => Navigator.pop(context),
          )
        ]).show();
  }
}
