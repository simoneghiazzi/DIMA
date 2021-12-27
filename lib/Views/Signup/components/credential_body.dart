import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/ViewModel/Forms/Authentication/credential_form.dart';

/// Body of the [CredentialScreen].
///
/// It contains the [CredentialForm] with the [FormTextField]s for signing up the user.
class CredentialBody extends StatefulWidget {
  /// Body of the [CredentialScreen].
  ///
  /// It contains the [CredentialForm] with the [FormTextField]s for signing up the user.
  const CredentialBody({Key? key}) : super(key: key);

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

    // Add a back button interceptor for listening to the OS back button
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
            // Title
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50.sp, fontFamily: "Gabriola"),
            ),
            // Form
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
                          inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                        ),
                        child: FormBlocListener<CredentialForm, String, String>(
                          onSuccess: (context, state) {
                            FocusScope.of(context).unfocus();
                            LoadingDialog.show(context);
                            // Set the email and sign up the new user
                            userViewModel.loggedUser!.email = credentialForm.emailText.value;
                            authViewModel.signUpUser(credentialForm.emailText.value, credentialForm.passwordText.value, userViewModel.loggedUser!);
                          },
                          child: Column(
                            children: <Widget>[
                              FormTextField(
                                textFieldBloc: credentialForm.emailText,
                                hintText: "Email",
                                prefixIconData: Icons.email,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              FormTextField(
                                textFieldBloc: credentialForm.passwordText,
                                hintText: "Password",
                                prefixIconData: Icons.lock,
                                suffixButton: SuffixButton.obscureText,
                                textCapitalization: TextCapitalization.none,
                                onChanged: (value) {
                                  if (credentialForm.confirmPasswordText.value.isNotEmpty) {
                                    credentialForm.confirmPasswordText.validate();
                                  }
                                },
                              ),
                              FormTextField(
                                textFieldBloc: credentialForm.confirmPasswordText,
                                hintText: "Confirm Password",
                                prefixIconData: Icons.lock,
                                suffixButton: SuffixButton.obscureText,
                                textCapitalization: TextCapitalization.none,
                              ),
                              SizedBox(height: 5.h),
                              // SignUp Button
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
            // Stream of the authMessage
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
                          text: TextSpan(text: snapshot.data, style: TextStyle(color: Colors.red, fontSize: 14.5.sp, fontWeight: FontWeight.bold)),
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
            // Go to SignIn Button
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: kPrimaryColor, fontSize: 12.sp)),
                  Text("Sign In", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12.5.sp)),
                ],
              ),
              onTap: () {
                authViewModel.clearAuthMessage();
                routerDelegate.replaceAllButNumber(1, routeSettingsList: [RouteSettings(name: LoginScreen.route)]);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Subscriber to the stream of user created. It returns a [StreamSubscription].
  ///
  /// If the user is created, it shows the snack bar and push the login page.
  StreamSubscription<bool> subscribeToUserCreatedStream() {
    return authViewModel.isUserCreated.listen((isUserCreated) {
      LoadingDialog.hide(context);
      if (isUserCreated) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Please check your email for the verification link."),
          duration: const Duration(seconds: 10),
        ));
        routerDelegate.replaceAllButNumber(1, routeSettingsList: [RouteSettings(name: LoginScreen.route)]);
      }
    });
  }

  /// Function called by the back button interceptor.
  ///
  /// It remove the current auth message if it is present and then pop the page.
  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    authViewModel.clearAuthMessage();
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
