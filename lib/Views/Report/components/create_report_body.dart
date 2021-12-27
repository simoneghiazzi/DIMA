import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/components/info_dialog.dart';
import 'package:sApport/Views/components/top_bar.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/Report/reports_list_screen.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:sApport/ViewModel/Forms/Report/report_form.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';

/// Body of the [CreateReportScreen].
///
/// It contains the [TopBar] with the button for the list of old reports
/// and the [ReportForm] for submitting a new report.
class CreateReportBody extends StatefulWidget {
  /// Body of the [CreateReportScreen].
  ///
  /// It contains the [TopBar] with the button for the list of old reports
  /// and the [ReportForm] for submitting a new report.
  const CreateReportBody({Key? key}) : super(key: key);

  @override
  _CreateReportBodyState createState() => _CreateReportBodyState();
}

class _CreateReportBodyState extends State<CreateReportBody> {
  // View Models
  late ReportViewModel reportViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(
          text: "New report",
          buttons: [
            // List Old Reports
            InkWell(
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.list_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 2.w),
                    Text("List", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onTap: () => routerDelegate.pushPage(name: ReportsListScreen.route),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: BlocProvider(
                create: (context) => ReportForm(),
                child: Builder(
                  builder: (context) {
                    ReportForm reportForm = BlocProvider.of<ReportForm>(context);
                    return Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: kPrimaryColor,
                        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.h),
                          Image.asset("assets/icons/safety.png", scale: 5),
                          Padding(
                            padding: EdgeInsets.only(top: 5.h, left: 40, right: 40),
                            child: FormBlocListener<ReportForm, String, String>(
                              onSubmitting: (context, state) {
                                LoadingDialog.show(context);
                              },
                              onSuccess: (context, state) {
                                reportViewModel.loadReports();
                                LoadingDialog.hide(context);
                                InfoDialog.show(context,
                                    infoType: InfoDialogType.success,
                                    content: "Report correctly submitted.",
                                    buttonType: ButtonType.ok,
                                    onTap: () => routerDelegate.pushPage(name: ReportsListScreen.route));
                              },
                              onFailure: (context, state) {
                                LoadingDialog.hide(context);
                                InfoDialog.show(context,
                                    infoType: InfoDialogType.error, content: "Error in submitting the report.", buttonType: ButtonType.ok);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  // Report Category
                                  DropdownFieldBlocBuilder<String>(
                                    emptyItemLabel: "Report category:",
                                    textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                    selectFieldBloc: reportForm.reportCategory,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: kPrimaryLightColor.withAlpha(100),
                                      labelText: "Report category",
                                      labelStyle: TextStyle(color: kPrimaryColor),
                                      prefixIcon: Icon(Icons.security, color: kPrimaryColor),
                                    ),
                                    itemBuilder: (context, value) => FieldItem(child: Text(value, style: TextStyle(color: kPrimaryColor))),
                                  ),
                                  SizedBox(height: 1.h),
                                  // Report Description
                                  TextFieldBlocBuilder(
                                    textCapitalization: TextCapitalization.sentences,
                                    textFieldBloc: reportForm.reportText,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: kPrimaryLightColor.withAlpha(100),
                                      labelText: "Report description",
                                      labelStyle: TextStyle(color: kPrimaryColor),
                                      prefixIcon: Icon(Icons.text_fields, color: kPrimaryColor),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  // Submit Button
                                  RoundedButton(
                                    text: "SUBMIT",
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      reportForm.submit();
                                    },
                                    enabled: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
