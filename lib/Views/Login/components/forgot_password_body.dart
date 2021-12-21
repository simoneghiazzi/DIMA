import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/rounded_input_field.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordBody extends StatefulWidget {
  @override
  _ForgotPasswordBodyState createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  late AuthViewModel authViewModel;
  late AppRouterDelegate routerDelegate;
  var _errorTextController = StreamController<String?>.broadcast();

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    BackButtonInterceptor.add(backButtonInterceptor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
            ),
            SizedBox(height: 2.h),
            StreamBuilder<String>(
                stream: authViewModel.loginForm.errorEmailText,
                builder: (context, snapshot) {
                  return RoundedInputField(
                    hintText: "Your Email",
                    controller: authViewModel.emailTextCtrl,
                    errorText: snapshot.data,
                  );
                }),
            StreamBuilder<String?>(
                stream: errorText,
                builder: (context, snapshot) {
                  return RichText(text: TextSpan(text: snapshot.data, style: TextStyle(color: Colors.red, fontSize: 15)));
                }),
            SizedBox(height: 3.h),
            StreamBuilder(
                stream: authViewModel.loginForm.isResetPasswordEnabled,
                builder: (context, AsyncSnapshot snapshot) {
                  return RoundedButton(
                    text: "Send link",
                    press: () async {
                      _errorTextController.add(null);
                      FocusScope.of(context).unfocus();
                      if (await authViewModel.hasPasswordAuthentication(authViewModel.emailTextCtrl.text)) {
                        authViewModel.resetPassword(authViewModel.emailTextCtrl.text);
                        showSnackBar();
                        routerDelegate.pop();
                      } else {
                        _errorTextController.add("No account found with this email.");
                      }
                    },
                    enabled: snapshot.data ?? false,
                  );
                }),
          ],
        ),
      ),
    );
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Please check your email for the password reset link.'),
      duration: const Duration(seconds: 20),
    ));
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    authViewModel.clearControllers();
    return true;
  }

  Stream<String?> get errorText => _errorTextController.stream;

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
