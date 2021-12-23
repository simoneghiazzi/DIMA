import 'dart:async';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Forms/Authentication/forgot_password_form.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/components/rounded_button.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "sApport",
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
              ),
              SizedBox(height: 3.h),
              Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: BlocProvider(
                  create: (context) => ForgotPasswordForm(),
                  child: Builder(
                    builder: (context) {
                      final forgotPasswordForm = BlocProvider.of<ForgotPasswordForm>(context, listen: false);
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: kPrimaryColor,
                          inputDecorationTheme: InputDecorationTheme(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        child: FormBlocListener<ForgotPasswordForm, String, String>(
                          onSuccess: (context, state) async {
                            _errorTextController.add(null);
                            FocusScope.of(context).unfocus();
                            if (await authViewModel.hasPasswordAuthentication(forgotPasswordForm.emailText.value)) {
                              authViewModel.resetPassword(forgotPasswordForm.emailText.value);
                              showSnackBar();
                              routerDelegate.pop();
                            } else {
                              _errorTextController.add("No account found with this email.");
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              TextFieldBlocBuilder(
                                textFieldBloc: forgotPasswordForm.emailText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: kPrimaryDarkColor),
                                  prefixIcon: Icon(Icons.email, color: kPrimaryColor),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              RoundedButton(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  forgotPasswordForm.submit();
                                },
                                text: "SEND LINK",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              StreamBuilder<String?>(
                stream: errorText,
                builder: (context, snapshot) {
                  return RichText(text: TextSpan(text: snapshot.data, style: TextStyle(color: Colors.red, fontSize: 15)));
                },
              ),
            ],
          ),
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

  Stream<String?> get errorText => _errorTextController.stream;
}
