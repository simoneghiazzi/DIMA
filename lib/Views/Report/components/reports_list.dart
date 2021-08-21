import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/report_view_model.dart';
import 'package:flutter/material.dart';

class ReportsListPage extends StatelessWidget {
  final AuthViewModel authViewModel;
  final ReportViewModel reportViewModel;

  ReportsListPage(
      {Key key, @required this.authViewModel, @required this.reportViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Colors.indigo[400],
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        child: Scaffold(
            body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(right: 16, top: 10),
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
                            "Reports list",
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
                            color: Colors.lightBlue[200],
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.indigo[500],
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "New",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
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
            ],
          ),
        )));
  }
}
