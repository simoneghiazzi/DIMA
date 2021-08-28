import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/report_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/reports_list_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/create_report_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CreateReportBody extends StatefulWidget {
  final BaseUserViewModel baseUserViewModel;

  CreateReportBody({Key key, @required this.baseUserViewModel})
      : super(key: key);

  @override
  _CreateReportBodyState createState() =>
      _CreateReportBodyState(baseUserViewModel: baseUserViewModel);
}

class _CreateReportBodyState extends State<CreateReportBody> {
  final BaseUserViewModel baseUserViewModel;
  ReportViewModel reportViewModel;

  _CreateReportBodyState({@required this.baseUserViewModel});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          ReportViewModel(loggedId: widget.baseUserViewModel.id),
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
                                      return ReportListScreen(
                                          reportViewModel: reportViewModel);
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
                                selectFieldBloc: reportViewModel.reportCategory,
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
                                textFieldBloc: reportViewModel.reportText,
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
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return ReportListScreen(reportViewModel: reportViewModel);
              },
            )).then((value) {
              Navigator.pop(context);
            });
          },
          color: kPrimaryColor,
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
              return CreateReportScreen(baseUserViewModel: widget.baseUserViewModel);
            })).then((value) {
              Navigator.pop(context);
            });
          },
          color: kPrimaryColor,
        )
      ],
    ).show();
  }
}
