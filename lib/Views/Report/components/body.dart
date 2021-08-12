import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/home.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/report_screen.dart';
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
      create: (context) => ReportViewModel(authViewModel: authViewModel),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<ReportViewModel>(context);
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
                  appBar: AppBar(
                      title: Text('Anonymous report'),
                      leading: new IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return Home(authViewModel: authViewModel);
                              },
                            ), (route) => true);
                          },
                          icon: new Icon(Icons.arrow_back))),
                  body: FormBlocListener<ReportViewModel, String, String>(
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
                    child: Container(
                      width: double.infinity,
                      height: size.height,
                      child: Stack(
                          alignment: Alignment.lerp(
                              Alignment.topCenter, Alignment.center, 0.7),
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                "assets/images/main_top.png",
                                width: size.width * 0.35,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Image.asset(
                                "assets/images/login_bottom.png",
                                width: size.width * 0.4,
                              ),
                            ),
                            SingleChildScrollView(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/icons/safety.png",
                                    height: size.height * 0.15,
                                  ),
                                  DropdownFieldBlocBuilder<String>(
                                    selectFieldBloc: formBloc.reportCategory,
                                    decoration: InputDecoration(
                                      labelText: 'Report category',
                                      prefixIcon: Icon(Icons.security),
                                    ),
                                    itemBuilder: (context, value) => value,
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.reportText,
                                    decoration: InputDecoration(
                                      labelText: 'Report description',
                                      prefixIcon: Icon(Icons.text_fields),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      formBloc.submit();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.indigoAccent[400],
                                    ),
                                    child: Text('SUBMIT'),
                                  )
                                ],
                              ),
                            ),
                          ]),
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
