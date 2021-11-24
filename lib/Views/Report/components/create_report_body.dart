import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/top_bar.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/reports_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/create_report_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CreateReportBody extends StatefulWidget {
  @override
  _CreateReportBodyState createState() => _CreateReportBodyState();
}

class _CreateReportBodyState extends State<CreateReportBody> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  BaseUserViewModel baseUserViewModel;
  ReportViewModel reportViewModel;
  AppRouterDelegate routerDelegate;
  Alert errorAlert;
  Alert successAlert;

  @override
  void initState() {
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    errorAlert = createErrorAlert();
    successAlert = createSuccessAlert();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => ReportViewModel(loggedId: baseUserViewModel.id),
      child: Builder(
        builder: (context) {
          reportViewModel = BlocProvider.of<ReportViewModel>(context);
          return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: kPrimaryColor,
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
                    TopBar(
                      text: 'New report',
                      button: InkWell(
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
                                Icons.book,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "List",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          routerDelegate.pushPage(
                              name: ReportsListScreen.route,
                              arguments: reportViewModel);
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    Image.asset(
                      "assets/icons/safety.png",
                      height: size.height * 0.15,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: size.height * 0.05, left: 40, right: 40),
                        child:
                            FormBlocListener<ReportViewModel, String, String>(
                          onSubmitting: (context, state) {
                            LoadingDialog.show(context, _keyLoader);
                          },
                          onSuccess: (context, state) {
                            Navigator.of(_keyLoader.currentContext,
                                    rootNavigator: true)
                                .pop();
                            _onReportSubmitted(context);
                          },
                          onFailure: (context, state) {
                            Navigator.of(_keyLoader.currentContext,
                                    rootNavigator: true)
                                .pop();
                            _onReportError(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              DropdownFieldBlocBuilder<String>(
                                selectFieldBloc: reportViewModel.reportCategory,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: 'Report category',
                                  labelStyle: TextStyle(color: kPrimaryColor),
                                  prefixIcon: Icon(
                                    Icons.security,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                itemBuilder: (context, value) => value,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              TextFieldBlocBuilder(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textFieldBloc: reportViewModel.reportText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: 'Report description',
                                  labelStyle: TextStyle(color: kPrimaryColor),
                                  prefixIcon: Icon(
                                    Icons.text_fields,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.06,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  reportViewModel.submit();
                                },
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        Size(size.width / 2, size.height / 20)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            kPrimaryColor),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(29)))),
                                child: Text('SUBMIT'),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              )));
        },
      ),
    );
  }

  _onReportSubmitted(context) {
    successAlert.show();
  }

  _onReportError(context) {
    errorAlert.show();
  }

  Alert createSuccessAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "Report submitted",
      type: AlertType.success,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            routerDelegate.pushPage(
                name: ReportsListScreen.route, arguments: reportViewModel);
            successAlert.dismiss();
          },
          color: Colors.transparent,
        )
      ],
    );
  }

  Alert createErrorAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "AN ERROR OCCURED",
      type: AlertType.error,
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            routerDelegate.replace(name: CreateReportScreen.route);
            errorAlert.dismiss();
          },
          color: kPrimaryColor,
        )
      ],
    );
  }
}
