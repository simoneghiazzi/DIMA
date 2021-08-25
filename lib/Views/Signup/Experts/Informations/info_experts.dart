import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/info_experts_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/Mail/signup_experts_mail_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/signup_experts_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../constants.dart';

class InfoExperts extends StatefulWidget {
  final AuthViewModel authViewModel;
  InfoExpertsViewModel formBloc;

  InfoExperts({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _InfoExpertsState createState() => _InfoExpertsState();
}

class _InfoExpertsState extends State<InfoExperts> {
  @override
  void initState() {
    super.initState();
  }

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
                  authViewModel: widget.authViewModel, context: context),
              child: Builder(
                builder: (context) {
                  widget.formBloc =
                      BlocProvider.of<InfoExpertsViewModel>(context);
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
                          setState(() {});
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
                                        textFieldBloc: widget.formBloc.nameText,
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
                                        textFieldBloc:
                                            widget.formBloc.surnameText,
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
                                        dateTimeFieldBloc:
                                            widget.formBloc.birthDate,
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
                                      TextFieldBlocBuilder(
                                        textFieldBloc:
                                            widget.formBloc.countryText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office country',
                                          prefixIcon: Icon(
                                            Icons.streetview,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc: widget.formBloc.cityText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office city',
                                          prefixIcon: Icon(
                                            Icons.location_city,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc:
                                            widget.formBloc.streetText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office street',
                                          prefixIcon: Icon(
                                            Icons.location_city,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc:
                                            widget.formBloc.addressNumberText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Office house number',
                                          prefixIcon: Icon(
                                            Icons.house,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      TextFieldBlocBuilder(
                                        textFieldBloc:
                                            widget.formBloc.phoneNumberText,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: kPrimaryLightColor,
                                          labelText: 'Phone number',
                                          prefixIcon: Icon(
                                            Icons.phone,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.04),
                                      ElevatedButton(
                                        onPressed: () {
                                          widget.formBloc.submit();
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
                                                  authViewModel:
                                                      widget.authViewModel,
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
              return SignUpExperts(authViewModel: widget.authViewModel);
            }));
          },
          color: kPrimaryColor,
        )
      ],
    ).show();
  }

  _addressConfirmation(context) {
    Alert(
      closeIcon: null,
      context: context,
      title: "FOUND ADDRESS: " + widget.formBloc.infoAddress,
      desc: "YOUR PERSONAL INFORMATIONS: \n" +
          "Name: " +
          widget.formBloc.nameText.value +
          "\n" +
          "Surname: " +
          widget.formBloc.surnameText.value +
          "\n" +
          "Date of birth: " +
          DateFormat('MM-dd-yyyy').format(widget.formBloc.birthDate.value) +
          "\n" +
          "Phone number: " +
          widget.formBloc.phoneNumberText.value,
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
            LoadingDialog.hide(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SignUpExpertsMail(
                      authViewModel: widget.authViewModel,
                      name: widget.formBloc.nameText.value,
                      surname: widget.formBloc.surnameText.value,
                      birthDate: widget.formBloc.birthDate.value,
                      phoneNumber: widget.formBloc.phoneNumberText.value,
                      latLng: LatLng(
                          widget.formBloc.expertAddress.geometry.location.lat,
                          widget.formBloc.expertAddress.geometry.location.lng));
                },
              ),
            ).then((value) {});
          },
          color: kPrimaryColor,
        ),
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return SignUpExperts(authViewModel: widget.authViewModel);
            }));
          },
          color: Colors.red,
        )
      ],
    ).show();
  }
}
