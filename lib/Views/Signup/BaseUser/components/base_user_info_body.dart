import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/credential_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_check.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:provider/provider.dart';

class BaseUserInfoBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Background(
        child: SingleChildScrollView(
            child: Padding(
      padding: EdgeInsets.only(left: 40, right: 40),
      child: Column(children: <Widget>[
        BlocProvider(
          create: (context) => BaseUserInfoViewModel(),
          child: Builder(
            builder: (context) {
              final infoViewModel = BlocProvider.of<BaseUserInfoViewModel>(
                  context,
                  listen: false);
              return Theme(
                  data: Theme.of(context).copyWith(
                    primaryColor: kPrimaryColor,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  child:
                      FormBlocListener<BaseUserInfoViewModel, String, String>(
                    onSubmitting: (context, state) {},
                    onSuccess: (context, state) {
                      routerDelegate.pushPage(
                          name: CredentialScreen.route,
                          arguments: InfoArguments(
                            infoViewModel,
                            Provider.of<BaseUserViewModel>(context,
                                listen: false),
                          ));
                    },
                    onFailure: (context, state) {
                      //Add what to do
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: size.height * 0.08),
                        Text(
                          "Personal information",
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
                        SizedBox(height: size.height * 0.05),
                        TextFieldBlocBuilder(
                          textCapitalization: TextCapitalization.sentences,
                          textFieldBloc: infoViewModel.nameText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kPrimaryLightColor,
                            labelText: 'First name',
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textCapitalization: TextCapitalization.sentences,
                          textFieldBloc: infoViewModel.surnameText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kPrimaryLightColor,
                            labelText: 'Last name',
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                        DateTimeFieldBlocBuilder(
                          dateTimeFieldBloc: infoViewModel.birthDateTime,
                          format: DateFormat.yMEd(),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: kPrimaryLightColor,
                              labelText: 'Birth date',
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: kPrimaryColor,
                              )),
                        ),
                        SizedBox(height: size.height * 0.02),
                        RoundedButton(
                          press: () {
                            FocusScope.of(context).unfocus();
                            infoViewModel.submit();
                          },
                          text: "NEXT",
                        ),
                        SizedBox(height: size.height * 0.05),
                        AlreadyHaveAnAccountCheck(
                          login: false,
                          press: () {
                            routerDelegate.replace(name: LoginScreen.route);
                          },
                        ),
                        SizedBox(height: size.height * 0.05),
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
