import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/info_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Users/Mail/signup_mail_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Users/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../../constants.dart';

class InfoBody extends StatelessWidget {
  final AuthViewModel authViewModel;

  InfoBody({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
        child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BlocProvider(
                      create: (context) => InfoViewModel(
                          authViewModel: authViewModel, context: context),
                      child: Builder(
                        builder: (context) {
                          final formBloc =
                              BlocProvider.of<InfoViewModel>(context);
                          return Theme(
                              data: Theme.of(context).copyWith(
                                primaryColor: kPrimaryColor,
                                inputDecorationTheme: InputDecorationTheme(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              child: FormBlocListener<InfoViewModel, String,
                                  String>(
                                onSubmitting: (context, state) {
                                  LoadingDialog.show(context);
                                },
                                onSuccess: (context, state) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SignUpMail(
                                            authViewModel: authViewModel,
                                            name: formBloc.nameText.value,
                                            surname: formBloc.surnameText.value,
                                            birthDate: formBloc.birthDate.value
                                                .toString());
                                      },
                                    ),
                                  );
                                },
                                onFailure: (context, state) {
                                  //Add what to do
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: size.height,
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
                                      SizedBox(height: size.height * 0.07),
                                      TextFieldBlocBuilder(
                                        textFieldBloc: formBloc.nameText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'First name',
                                          prefixIcon: Icon(Icons.text_fields),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc: formBloc.surnameText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Last name',
                                          prefixIcon: Icon(Icons.text_fields),
                                        ),
                                      ),
                                      DateTimeFieldBlocBuilder(
                                        dateTimeFieldBloc: formBloc.birthDate,
                                        format: DateFormat.yMEd(),
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1920),
                                        lastDate: DateTime.now(),
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: kPrimaryLightColor,
                                            labelText: 'Birth date',
                                            prefixIcon: Icon(Icons.date_range)),
                                      ),
                                      SizedBox(height: size.height * 0.04),
                                      ElevatedButton(
                                        onPressed: () {
                                          formBloc.submit();
                                        },
                                        style: ButtonStyle(
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                                    Size(size.width / 2,
                                                        size.height / 20)),
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    kPrimaryColor),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            29)))),
                                        child: Text('NEXT'),
                                      ),
                                      SizedBox(height: size.height * 0.06),
                                      AlreadyHaveAnAccountCheck(
                                        login: false,
                                        press: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return LoginScreen(
                                                  authViewModel: authViewModel,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
                    ),
                  ]),
            )));
  }
}
