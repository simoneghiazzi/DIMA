import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

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
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          "Reports",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
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
            Container(
              child: Stack(
                children: <Widget>[
                  // List
                  Container(
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
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot doc) {
    // This size provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    if (doc != null) {
      return Container(
        child: TextButton(
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 30.0,
                child: Image.asset(
                  "assets/icons/logo.png",
                  height: size.height * 0.05,
                ),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          doc.get('date'),
                          maxLines: 1,
                          style: TextStyle(color: Color(0xff203152)),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xffE8E8E8)),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
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
}
