import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/Signup/components/background.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:provider/provider.dart';

class BaseUserInfoBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserViewModel userViewModel = Provider.of<UserViewModel>(context, listen: false);
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    Size size = MediaQuery.of(context).size;

    return Background(
        child: SingleChildScrollView(
            child: Padding(
      padding: EdgeInsets.only(left: 40, right: 40),
      child: Column(children: <Widget>[
        BlocProvider(
          create: (context) => BaseUserSignUpForm(),
          child: Builder(
            builder: (context) {
              final baseUserSignUpForm = BlocProvider.of<BaseUserSignUpForm>(context, listen: false);
              return Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: kPrimaryColor,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  child: FormBlocListener<BaseUserSignUpForm, String, String>(
                    onSubmitting: (context, state) {},
                    onSuccess: (context, state) {
                      userViewModel.createUser(baseUserSignUpForm);
                      routerDelegate.pushPage(name: CredentialScreen.route);
                    },
                    onFailure: (context, state) {
                      // Add what to do
                    },
                    child: Column(
                      children: <Widget>[
                        Text(
                          "sApport",
                          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
                        ),
                        Text(
                          "Sign up to share your personal story with other anonymous users or to find a suitable expert for you.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kPrimaryDarkColorTrasparent, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Divider(),
                        SizedBox(height: size.height * 0.03),
                        TextFieldBlocBuilder(
                          textCapitalization: TextCapitalization.sentences,
                          textFieldBloc: baseUserSignUpForm.nameText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kPrimaryLightColor.withAlpha(100),
                            labelText: "First name",
                            labelStyle: TextStyle(color: kPrimaryColor),
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textCapitalization: TextCapitalization.sentences,
                          textFieldBloc: baseUserSignUpForm.surnameText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kPrimaryLightColor.withAlpha(100),
                            labelText: "Last name",
                            labelStyle: TextStyle(color: kPrimaryColor),
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
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
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: kPrimaryColor,
                              )),
                        ),
                        SizedBox(height: size.height * 0.04),
                        RoundedButton(
                          press: () {
                            FocusScope.of(context).unfocus();
                            baseUserSignUpForm.submit();
                          },
                          text: "NEXT",
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ),
      ]),
    )));
  }
}
