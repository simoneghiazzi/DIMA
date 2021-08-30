import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/background.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/credential_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

import '../experts_signup_screen.dart';

class ExpertsInfoBody extends StatefulWidget {
  final AuthViewModel authViewModel;

  ExpertsInfoBody({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _ExpertsInfoBodyState createState() =>
      _ExpertsInfoBodyState(authViewModel: authViewModel);
}

class _ExpertsInfoBodyState extends State<ExpertsInfoBody> {
  final AuthViewModel authViewModel;
  ExpertInfoViewModel expertInfoViewModel;
  bool nextEnabled;

  _ExpertsInfoBodyState({@required this.authViewModel});

  @override
  void initState() {
    super.initState();
    nextEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                BlocProvider(
                  create: (context) => ExpertInfoViewModel(),
                  child: Builder(
                    builder: (context) {
                      expertInfoViewModel =
                          BlocProvider.of<ExpertInfoViewModel>(context);
                      return Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: kPrimaryColor,
                            inputDecorationTheme: InputDecorationTheme(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          child: FormBlocListener<ExpertInfoViewModel, String,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  textFieldBloc: expertInfoViewModel.nameText,
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
                                      expertInfoViewModel.surnameText,
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
                                      expertInfoViewModel.birthDateTime,
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
                                      expertInfoViewModel.countryText,
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
                                  textFieldBloc: expertInfoViewModel.cityText,
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
                                  textFieldBloc: expertInfoViewModel.streetText,
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
                                      expertInfoViewModel.addressNumberText,
                                  keyboardType: TextInputType.number,
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
                                      expertInfoViewModel.phoneNumberText,
                                  keyboardType: TextInputType.number,
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
                              ],
                            ),
                          ));
                    },
                  ),
                ),
                FormBuilderImagePicker(
                    name: 'photo',
                    decoration:
                        const InputDecoration(labelText: 'Profile photo'),
                    maxImages: 1,
                    onChanged: (image) {
                      if (image.isNotEmpty) {
                        expertInfoViewModel.profilePhoto =
                            image[0].path.toString();
                        setState(() {
                          nextEnabled = true;
                        });
                      }
                    },
                    validator: FormBuilderValidators.required(context)),
                SizedBox(height: size.height * 0.04),
                RoundedButton(
                  text: "NEXT",
                  press: () {
                    expertInfoViewModel.submit();
                  },
                  enabled: nextEnabled,
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
                            authViewModel: widget.authViewModel,
                          );
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.06),
              ],
            ),
          )),
    );
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
              return ExpertsSignUpScreen(authViewModel: authViewModel);
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
      title: "Found address: " + expertInfoViewModel.infoAddress,
      desc: "Your personal informations: \n" +
          "Name: " +
          expertInfoViewModel.values['name'] +
          "\n" +
          "Surname: " +
          expertInfoViewModel.values['surname'] +
          "\n" +
          "Date of birth: " +
          DateFormat('MM-dd-yyyy')
              .format(expertInfoViewModel.values['birthDate']) +
          "\n" +
          "Phone number: " +
          expertInfoViewModel.values['phoneNumber'],
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "CONFIRM",
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CredentialScreen(
                      authViewModel: authViewModel,
                      infoViewModel: expertInfoViewModel,
                      userViewModel: ExpertViewModel());
                },
              ),
            ).then((value) {
              setState(() {});
            });
          },
          color: kPrimaryColor,
        ),
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return ExpertsSignUpScreen(authViewModel: widget.authViewModel);
            }));
          },
          color: Colors.transparent,
        )
      ],
    ).show();
  }
}
