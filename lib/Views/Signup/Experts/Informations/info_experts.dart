import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/info_experts_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/Mail/signup_experts_mail_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/signup_experts_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants.dart';

class InfoExperts extends StatelessWidget {
  final AuthViewModel authViewModel;
  InfoExpertsViewModel formBloc;

  InfoExperts({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
        child: Padding(
      padding: EdgeInsets.only(left: 40, right: 40),
      child: SingleChildScrollView(
          child: Stack(alignment: Alignment.center,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
            BlocProvider(
              create: (context) => InfoExpertsViewModel(
                  authViewModel: authViewModel, context: context),
              child: Builder(
                builder: (context) {
                  formBloc = BlocProvider.of<InfoExpertsViewModel>(context);
                  return Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: kPrimaryColor,
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      child: FormBlocListener<InfoExpertsViewModel, String,
                          String>(
                        onSubmitting: (context, state) {
                          LoadingDialog.show(context);
                        },
                        onSuccess: (context, state) {
                          _addressConfirmation(context);
                        },
                        onFailure: (context, state) {
                          _onAddressError(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: size.height,
                          child: Stack(
                              alignment: Alignment.lerp(
                                  Alignment.topCenter, Alignment.center, 0.6),
                              children: <Widget>[
                                SingleChildScrollView(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                      SizedBox(height: size.height * 0.04),
                                      Image.asset(
                                        "assets/icons/logo.png",
                                        height: size.height * 0.15,
                                      ),
                                      SizedBox(height: size.height * 0.04),
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
                                      TextFieldBlocBuilder(
                                        textFieldBloc: formBloc.countryText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office country',
                                          prefixIcon: Icon(Icons.streetview),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc: formBloc.cityText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office city',
                                          prefixIcon: Icon(Icons.location_city),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc: formBloc.streetText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office street',
                                          prefixIcon: Icon(Icons.location_city),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc:
                                            formBloc.addressNumberText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office house number',
                                          prefixIcon: Icon(Icons.house),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc: formBloc.phoneNumberText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Phone number',
                                          prefixIcon: Icon(Icons.phone),
                                        ),
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
                                      SizedBox(height: size.height * 0.06),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ));
                },
              ),
            )
          ])),
    ));
  }

  _onAddressError(context) {
    Alert(
      closeIcon: null,
      context: context,
      title: "NO ADDRESS FOUND",
      type: AlertType.error,
      style: AlertStyle(
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return SignUpExperts(authViewModel: authViewModel);
            }));
          },
          gradient: LinearGradient(colors: [
            Colors.indigo[400],
            Colors.cyan[200],
          ]),
        )
      ],
    ).show();
  }

  _addressConfirmation(context) {
    Alert(
      closeIcon: null,
      context: context,
      title: "FOUND ADDRESS: " + formBloc.infoAddress,
      desc: "YOUR PERSONAL INFORMATIONS: \n" +
          "Name: " +
          formBloc.nameText.value +
          "\n" +
          "Surname: " +
          formBloc.surnameText.value +
          "\n" +
          "Date of birth: " +
          DateFormat('MM-dd-yyyy').format(formBloc.birthDate.value) +
          "\n" +
          "Phone number: " +
          formBloc.phoneNumberText.value,
      type: AlertType.info,
      style: AlertStyle(
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "CONFIRM",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SignUpExpertsMail(
                      authViewModel: authViewModel,
                      name: formBloc.nameText.value,
                      surname: formBloc.surnameText.value,
                      birthDate: formBloc.birthDate.value,
                      phoneNumber: formBloc.phoneNumberText.value,
                      latLng: LatLng(
                          formBloc.expertAddress.geometry.location.lat,
                          formBloc.expertAddress.geometry.location.lng));
                },
              ),
            );
          },
          gradient: LinearGradient(colors: [
            Colors.indigo[400],
            Colors.cyan[200],
          ]),
        ),
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return SignUpExperts(authViewModel: authViewModel);
            }));
          },
          gradient: LinearGradient(colors: [
            Colors.red[400],
            Colors.red[200],
          ]),
        )
      ],
    ).show();
  }
}
