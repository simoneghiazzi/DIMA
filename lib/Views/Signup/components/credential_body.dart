import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Forms/Authentication/credential_form.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CredentialBody extends StatefulWidget {
  @override
  _CredentialBodyState createState() => _CredentialBodyState();
}

class _CredentialBodyState extends State<CredentialBody> {
  // View Models
  late AuthViewModel authViewModel;
  late UserViewModel userViewModel;
  late AppRouterDelegate routerDelegate;

  // Subscriber
  late StreamSubscription<bool> subscriber;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    subscriber = subscribeToUserCreatedStream();
    BackButtonInterceptor.add(backButtonInterceptor);
    //WidgetsBinding.instance!.addPostFrameCallback((_) => authViewModel.getData());
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
            Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: BlocProvider(
                  create: (context) => CredentialForm(),
                  child: Builder(
                    builder: (context) {
                      final credentialForm = BlocProvider.of<CredentialForm>(context, listen: false);
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: kPrimaryColor,
                          inputDecorationTheme: InputDecorationTheme(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        child: FormBlocListener<CredentialForm, String, String>(
                          onSuccess: (context, state) {
                            FocusScope.of(context).unfocus();
                            LoadingDialog.show(context);
                            userViewModel.loggedUser!.email = credentialForm.emailText.value;
                            authViewModel.signUpUser(credentialForm.emailText.value, credentialForm.passwordText.value, userViewModel.loggedUser!);
                          },
                          child: Column(
                            children: <Widget>[
                              TextFieldBlocBuilder(
                                textFieldBloc: credentialForm.emailText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: kPrimaryDarkColor),
                                  prefixIcon: Icon(Icons.email, color: kPrimaryColor),
                                ),
                              ),
                              TextFieldBlocBuilder(
                                onChanged: (value) {
                                  if (credentialForm.confirmPasswordText.value.isNotEmpty) {
                                    credentialForm.confirmPasswordText.validate();
                                  }
                                },
                                textFieldBloc: credentialForm.passwordText,
                                suffixButton: SuffixButton.obscureText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: kPrimaryColor),
                                  prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                                ),
                              ),
                              TextFieldBlocBuilder(
                                textFieldBloc: credentialForm.confirmPasswordText,
                                suffixButton: SuffixButton.obscureText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Confirm Password",
                                  labelStyle: TextStyle(color: kPrimaryColor),
                                  prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              RoundedButton(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  credentialForm.submit();
                                },
                                text: "SIGNUP",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            StreamBuilder<String?>(
              stream: authViewModel.authMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: snapshot.data,
                            style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  );
                } else {
                  return SizedBox(height: 5.h);
                }
              },
            ),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              onTap: () {
                //authViewModel.clearControllers();
                routerDelegate.replaceAllButNumber(1, routeSettingsList: [RouteSettings(name: LoginScreen.route)]);
              },
            ),
          ],
        ),
      ),
    );
  }

  StreamSubscription<bool> subscribeToUserCreatedStream() {
    return authViewModel.isUserCreated.listen((isUserCreated) {
      LoadingDialog.hide(context);
      if (isUserCreated) {
        showSnackBar();
        routerDelegate.pushPage(name: LoginScreen.route);
      }
    });
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Please check your email for the verification link."),
      duration: const Duration(seconds: 10),
    ));
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //authViewModel.clearControllers();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    subscriber.cancel();
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
