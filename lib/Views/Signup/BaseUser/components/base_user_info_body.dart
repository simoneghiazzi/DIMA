import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Signup/components/background.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/ViewModel/Forms/Authentication/base_user_signup_form.dart';

/// Body of the [BaseUsersSignUpScreen].
///
/// It contains the [BaseUserSignUpForm] with the [FormTextField]s for gathering the
/// [BaseUser] profile information.
class BaseUserInfoBody extends StatelessWidget {
  /// Body of the [BaseUsersSignUpScreen].
  ///
  /// It contains the [BaseUserSignUpForm] with the [FormTextField]s for gathering the
  /// [BaseUser] profile information.
  const BaseUserInfoBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // View Models
    UserViewModel userViewModel = Provider.of<UserViewModel>(context, listen: false);
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Column(
            children: <Widget>[
              // Title
              Text(
                "sApport",
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50.sp, fontFamily: "Gabriola"),
              ),
              // Subtitle
              Text(
                "Sign up to share your personal story with other anonymous users or to find a suitable expert for you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: kPrimaryDarkColorTrasparent, fontWeight: FontWeight.bold, fontSize: 12.5.sp),
              ),
              SizedBox(height: 3.h),
              Divider(),
              SizedBox(height: 3.h),
              // Form
              Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: BlocProvider(
                  create: (context) => BaseUserSignUpForm(),
                  child: Builder(
                    builder: (context) {
                      final baseUserSignUpForm = BlocProvider.of<BaseUserSignUpForm>(context, listen: false);
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: kPrimaryColor,
                          inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                        ),
                        child: FormBlocListener<BaseUserSignUpForm, String, String>(
                          onSuccess: (context, state) {
                            userViewModel.createUser(baseUserSignUpForm);
                            routerDelegate.pushPage(name: CredentialScreen.route);
                          },
                          child: Column(
                            children: <Widget>[
                              FormTextField(textFieldBloc: baseUserSignUpForm.nameText, hintText: "First name", prefixIconData: Icons.text_fields),
                              FormTextField(textFieldBloc: baseUserSignUpForm.surnameText, hintText: "Last name", prefixIconData: Icons.text_fields),
                              DateTimeFieldBlocBuilder(
                                dateTimeFieldBloc: baseUserSignUpForm.birthDate,
                                format: DateFormat.yMEd(),
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Birth date",
                                  labelStyle: TextStyle(color: kPrimaryColor),
                                  prefixIcon: Icon(Icons.date_range, color: kPrimaryColor),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              // Next Button
                              RoundedButton(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  baseUserSignUpForm.submit();
                                },
                                text: "NEXT",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
