import 'dart:io';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Forms/expert_signup_form.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Signup/components/background.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/already_have_an_account_check.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ExpertsInfoBody extends StatefulWidget {
  @override
  _ExpertsInfoBodyState createState() => _ExpertsInfoBodyState();
}

class _ExpertsInfoBodyState extends State<ExpertsInfoBody> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  UserViewModel userViewModel;
  ExpertSignUpForm expertSignUpForm;
  AppRouterDelegate routerDelegate;
  bool nextEnabled = false;
  File _image;
  Alert errorAlert;
  Alert addressConfirmationAlert;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    errorAlert = createErrorAlert();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          children: <Widget>[
            BlocProvider(
              create: (context) => ExpertSignUpForm(),
              child: Builder(
                builder: (context) {
                  expertSignUpForm = BlocProvider.of<ExpertSignUpForm>(context, listen: false);
                  return Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: kPrimaryColor,
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      child: FormBlocListener<ExpertSignUpForm, String, String>(
                        onSubmitting: (context, state) {
                          LoadingDialog.show(context, _keyLoader);
                        },
                        onSuccess: (context, state) {
                          addressConfirmationAlert = createAddressConfirmationAlert();
                          addressConfirmationAlert.show();
                        },
                        onFailure: (context, state) {
                          errorAlert.show();
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
                              textCapitalization: TextCapitalization.sentences,
                              textFieldBloc: expertSignUpForm.nameText,
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
                              textFieldBloc: expertSignUpForm.surnameText,
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
                              dateTimeFieldBloc: expertSignUpForm.birthDate,
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
                            TextFieldBlocBuilder(
                              textCapitalization: TextCapitalization.sentences,
                              textFieldBloc: expertSignUpForm.countryText,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kPrimaryLightColor.withAlpha(100),
                                labelText: "Office country",
                                labelStyle: TextStyle(color: kPrimaryColor),
                                prefixIcon: Icon(
                                  Icons.streetview,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            TextFieldBlocBuilder(
                              textCapitalization: TextCapitalization.sentences,
                              textFieldBloc: expertSignUpForm.cityText,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kPrimaryLightColor.withAlpha(100),
                                labelText: "Office city",
                                labelStyle: TextStyle(color: kPrimaryColor),
                                prefixIcon: Icon(
                                  Icons.location_city,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            TextFieldBlocBuilder(
                              textCapitalization: TextCapitalization.sentences,
                              textFieldBloc: expertSignUpForm.streetText,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kPrimaryLightColor.withAlpha(100),
                                labelText: "Office street",
                                labelStyle: TextStyle(color: kPrimaryColor),
                                prefixIcon: Icon(
                                  Icons.location_city,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            TextFieldBlocBuilder(
                              textFieldBloc: expertSignUpForm.houseNumber,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kPrimaryLightColor.withAlpha(100),
                                labelText: "Office house number",
                                labelStyle: TextStyle(color: kPrimaryColor),
                                prefixIcon: Icon(
                                  Icons.house,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            TextFieldBlocBuilder(
                              textFieldBloc: expertSignUpForm.phoneNumber,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kPrimaryLightColor.withAlpha(100),
                                labelText: "Phone number",
                                labelStyle: TextStyle(color: kPrimaryColor),
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
            SizedBox(height: size.height * 0.04),
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: CircleAvatar(
                radius: size.width / 3.9,
                backgroundColor: kPrimaryColor,
                child: CircleAvatar(
                  radius: size.width / 4,
                  backgroundColor: kPrimaryLightColor,
                  child: ClipOval(
                    child: new SizedBox(
                      width: 180.0,
                      height: 180.0,
                      child: (_image != null)
                          ? Image.file(
                              _image,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/icons/logo_circular.png",
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            RoundedButton(
              text: "NEXT",
              press: () {
                FocusScope.of(context).unfocus();
                expertSignUpForm.submit();
              },
              enabled: nextEnabled,
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                routerDelegate.replace(name: LoginScreen.route);
              },
            ),
            SizedBox(height: size.height * 0.06),
          ],
        ),
      )),
    );
  }

  Alert createErrorAlert() {
    return Alert(
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
            errorAlert.dismiss();
            LoadingDialog.hide(context, _keyLoader);
          },
          color: kPrimaryColor,
        )
      ],
    );
  }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      expertSignUpForm.profilePhoto = image.path.toString();
      setState(() {
        _image = File(image.path);
        nextEnabled = true;
      });
    }
  }

  Alert createAddressConfirmationAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "Found address: " + expertSignUpForm.infoAddress,
      desc: "Your personal informations: \n" +
          "Name: " +
          expertSignUpForm.data["name"] +
          "\n" +
          "Surname: " +
          expertSignUpForm.data["surname"] +
          "\n" +
          "Date of birth: " +
          DateFormat('MM-dd-yyyy').format(expertSignUpForm.data["birthDate"]) +
          "\n" +
          "Phone number: " +
          expertSignUpForm.data["phoneNumber"],
      style: AlertStyle(
        animationDuration: Duration(milliseconds: 0),
        isCloseButton: false,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "CONFIRM",
            style: TextStyle(color: kPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            userViewModel.createUser(Collection.EXPERTS, expertSignUpForm);
            addressConfirmationAlert.dismiss();
            LoadingDialog.hide(context, _keyLoader);
            routerDelegate.pushPage(name: CredentialScreen.route);
          },
          color: Colors.transparent,
        ),
        DialogButton(
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            addressConfirmationAlert.dismiss();
            LoadingDialog.hide(context, _keyLoader);
          },
          color: Colors.transparent,
        )
      ],
    );
  }
}
