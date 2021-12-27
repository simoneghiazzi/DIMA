import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/ViewModel/Forms/Authentication/forgot_password_form.dart';

/// Body of the [ForgotPasswordScreen].
///
/// It contains the [ForgotPasswordForm] with the [FormTextField] for sending
/// the email with the reset password link.
class ForgotPasswordBody extends StatefulWidget {
  /// Body of the [ForgotPasswordScreen].
  ///
  /// It contains the [ForgotPasswordForm] with the [FormTextField] for sending
  /// the email with the reset password link.
  const ForgotPasswordBody({Key? key}) : super(key: key);

  @override
  _ForgotPasswordBodyState createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  // View Models
  late AuthViewModel authViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Stream Controller
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
              // Title
              Text(
                "sApport",
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50.sp, fontFamily: "Gabriola"),
              ),
              SizedBox(height: 3.h),
              // Form
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
                          inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                        ),
                        child: FormBlocListener<ForgotPasswordForm, String, String>(
                          onSuccess: (context, state) async {
                            _errorTextController.add(null);
                            FocusScope.of(context).unfocus();
                            // Check if the user has the email/password as authentication method
                            if (await authViewModel.hasPasswordAuthentication(forgotPasswordForm.emailText.value)) {
                              authViewModel.resetPassword(forgotPasswordForm.emailText.value);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Please check your email for the password reset link."),
                                duration: const Duration(seconds: 10),
                              ));
                              routerDelegate.pop();
                            } else {
                              _errorTextController.add("No account found with this email.");
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              // Email Text Field
                              FormTextField(
                                textFieldBloc: forgotPasswordForm.emailText,
                                hintText: "Email",
                                prefixIconData: Icons.email,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 5.h),
                              // Button
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
              // Stream of the _errorText
              StreamBuilder<String?>(
                stream: errorText,
                builder: (context, snapshot) => RichText(text: TextSpan(text: snapshot.data, style: TextStyle(color: Colors.red, fontSize: 15))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Stream of the [_errorTextController].
  Stream<String?> get errorText => _errorTextController.stream;
}
