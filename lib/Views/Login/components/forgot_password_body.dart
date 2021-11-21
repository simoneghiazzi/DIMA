import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_input_field.dart';
import 'package:provider/provider.dart';

class ForgotPasswordBody extends StatefulWidget {
  @override
  _ForgotPasswordBodyState createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    BackButtonInterceptor.add(backButtonInterceptor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Reset Password",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: size.height * 0.08),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.08),
            StreamBuilder<String>(
                stream: authViewModel.loginForm.errorEmailText,
                builder: (context, snapshot) {
                  return RoundedInputField(
                    hintText: "Your Email",
                    controller: authViewModel.emailController,
                    errorText: snapshot.data,
                  );
                }),
            SizedBox(height: size.height * 0.05),
            StreamBuilder(
                stream: authViewModel.loginForm.isResetPasswordEnabled,
                builder: (context, snapshot) {
                  return RoundedButton(
                    text: "Send link",
                    press: () async {
                      FocusScope.of(context).unfocus();
                      await authViewModel
                          .resetPassword(authViewModel.emailController.text);
                      showSnackBar();
                      routerDelegate.pop();
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
      content:
          const Text('Please check your email for the password reset link.'),
      duration: const Duration(seconds: 20),
    ));
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    authViewModel.clearControllers();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
