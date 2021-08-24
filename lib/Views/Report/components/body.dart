import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/home.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/reports_list.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/report_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Body extends StatelessWidget {
  final AuthViewModel authViewModel;

  Body({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          ReportViewModel(loggedId: authViewModel.loggedUser.uid),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<ReportViewModel>(context);
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
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: kPrimaryColor,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                Text(
                                  "Reports",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ReportListPage(
                                          reportViewModel: formBloc);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
                            top: size.height * 0.1, left: 40, right: 40),
                        child:
                            FormBlocListener<ReportViewModel, String, String>(
                          onSubmitting: (context, state) {
                            LoadingDialog.show(context);
                          },
                          onSuccess: (context, state) {
                            LoadingDialog.hide(context);
                            _onReportSubmitted(context);
                          },
                          onFailure: (context, state) {
                            LoadingDialog.hide(context);
                            _onReportError(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              DropdownFieldBlocBuilder<String>(
                                selectFieldBloc: formBloc.reportCategory,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor,
                                  labelText: 'Report category',
                                  prefixIcon: Icon(
                                    Icons.security,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                itemBuilder: (context, value) => value,
                              ),
                              TextFieldBlocBuilder(
                                textFieldBloc: formBloc.reportText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor,
                                  labelText: 'Report description',
                                  prefixIcon: Icon(
                                    Icons.text_fields,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  formBloc.submit();
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
    Alert(
      closeIcon: null,
      context: context,
      title: "REPORT SUBMITTED",
      type: AlertType.success,
      style: AlertStyle(
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return Home(authViewModel: authViewModel);
              },
            ), (route) => true);
          },
          gradient: LinearGradient(colors: [
            Colors.indigo[400],
            Colors.cyan[200],
          ]),
        )
      ],
    ).show();
  }

  _onReportError(context) {
    Alert(
      closeIcon: null,
      context: context,
      title: "AN ERROR OCCURED",
      type: AlertType.error,
      style: AlertStyle(
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return ReportScreen(authViewModel: authViewModel);
            }));
          },
          gradient: LinearGradient(colors: [
            Colors.indigo[400],
            Colors.cyan[200],
          ]),
        )
      ],
    ).show();
  }
}
