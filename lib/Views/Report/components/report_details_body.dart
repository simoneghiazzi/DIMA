import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';

class ReportDetailsBody extends StatefulWidget {
  const ReportDetailsBody({Key? key}) : super(key: key);

  @override
  _ReportDetailsBodyState createState() => _ReportDetailsBodyState();
}

class _ReportDetailsBodyState extends State<ReportDetailsBody> with WidgetsBindingObserver {
  late ReportViewModel reportViewModel;
  late AppRouterDelegate routerDelegate;

  late Report _reportItem;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    _reportItem = reportViewModel.currentReport!;
    BackButtonInterceptor.add(backButtonInterceptor);
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
            TopBar(back: reportViewModel.resetCurrentReport, text: _reportItem.category),
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
                          DateFormat('dd MMM yyyy').format(_reportItem.dateTime!),
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
                      _reportItem.description,
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

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    reportViewModel.resetCurrentReport();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
