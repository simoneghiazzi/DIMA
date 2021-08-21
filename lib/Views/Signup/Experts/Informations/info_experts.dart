import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/info_experts_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Report/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/Mail/signup_experts_mail_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/signup_experts_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class InfoExperts extends StatelessWidget {
  final AuthViewModel authViewModel;
  InfoExpertsViewModel formBloc;

  InfoExperts({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          InfoExpertsViewModel(authViewModel: authViewModel, context: context),
      child: Builder(
        builder: (context) {
          formBloc = BlocProvider.of<InfoExpertsViewModel>(context);
          return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: Colors.indigo[400],
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              child: Scaffold(
                  appBar: AppBar(title: Text('Personal informations')),
                  body: FormBlocListener<InfoExpertsViewModel, String, String>(
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
                              Alignment.topCenter, Alignment.center, 0.7),
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Image.asset(
                                "assets/images/main_top.png",
                                width: size.width * 0.35,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Image.asset(
                                "assets/images/login_bottom.png",
                                width: size.width * 0.4,
                              ),
                            ),
                            SingleChildScrollView(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/icons/logo.png",
                                    height: size.height * 0.15,
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.nameText,
                                    decoration: InputDecoration(
                                      labelText: 'First name',
                                      prefixIcon: Icon(Icons.text_fields),
                                    ),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.surnameText,
                                    decoration: InputDecoration(
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
                                        labelText: 'Birth date',
                                        prefixIcon: Icon(Icons.date_range)),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.countryText,
                                    decoration: InputDecoration(
                                      labelText: 'Office country',
                                      prefixIcon: Icon(Icons.streetview),
                                    ),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.cityText,
                                    decoration: InputDecoration(
                                      labelText: 'Office city',
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.streetText,
                                    decoration: InputDecoration(
                                      labelText: 'Office street',
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.addressNumberText,
                                    decoration: InputDecoration(
                                      labelText: 'Office house number',
                                      prefixIcon: Icon(Icons.house),
                                    ),
                                  ),
                                  TextFieldBlocBuilder(
                                    textFieldBloc: formBloc.phoneNumberText,
                                    decoration: InputDecoration(
                                      labelText: 'Phone number',
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      formBloc.submit();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.indigoAccent[400],
                                    ),
                                    child: Text('NEXT'),
                                  )
                                ],
                              ),
                            ),
                          ]),
                    ),
                  )));
        },
      ),
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
