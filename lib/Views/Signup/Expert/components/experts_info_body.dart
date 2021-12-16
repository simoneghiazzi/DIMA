import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Forms/expert_signup_form.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Signup/components/background.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
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
  UserViewModel userViewModel;
  ExpertSignUpForm expertSignUpForm;
  AppRouterDelegate routerDelegate;
  bool nextEnabled = false;
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
                          LoadingDialog.show(context);
                        },
                        onSuccess: (context, state) {
                          LoadingDialog.hide(context);
                          addressConfirmationAlert = createAddressConfirmationAlert();
                          addressConfirmationAlert.show();
                        },
                        onFailure: (context, state) {
                          LoadingDialog.hide(context);
                          errorAlert.show();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: size.height * 0.1),
                            Text(
                              "sApport",
                              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
                            ),
                            Text(
                              "Sign up to increase your visibility and seize the opportunity for professional and personal growth.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: kPrimaryDarkColorTrasparent, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: size.height * 0.03),
                            Divider(),
                            SizedBox(height: size.height * 0.03),
                            GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: kPrimaryColor,
                                child: CircleAvatar(
                                  radius: 67,
                                  backgroundColor: kPrimaryLightColor,
                                  child: ClipOval(
                                      child: (expertSignUpForm.profilePhoto != null)
                                          ? Image.file(
                                              File(expertSignUpForm.profilePhoto),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage("assets/icons/logo_circular.png"),
                                                  scale: 4,
                                                  opacity: 0.1,
                                                ),
                                              ),
                                              child: Center(
                                                  child: Icon(
                                                Icons.add_a_photo,
                                                size: 40,
                                                color: kPrimaryColor,
                                              )))),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.03),
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
            RoundedButton(
              text: "NEXT",
              press: () {
                FocusScope.of(context).unfocus();
                expertSignUpForm.submit();
              },
              enabled: nextEnabled,
            ),
            SizedBox(height: size.height * 0.1),
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
      _cropImage(image.path);
    }
  }

  Future _cropImage(String imagePath) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "Cropper",
          toolbarColor: kPrimaryColor,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          title: "Cropper",
        ));
    if (croppedFile != null) {
      expertSignUpForm.profilePhoto = croppedFile.path;
      setState(() {
        nextEnabled = true;
      });
    }
  }

  Alert createAddressConfirmationAlert() {
    return Alert(
      closeIcon: null,
      context: context,
      title: "Found address: " + expertSignUpForm.expertAddress.address,
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
            userViewModel.createUser(expertSignUpForm);
            addressConfirmationAlert.dismiss();
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
            LoadingDialog.hide(context);
          },
          color: Colors.transparent,
        )
      ],
    );
  }
}
