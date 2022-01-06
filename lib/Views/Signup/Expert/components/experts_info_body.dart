import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Signup/credential_screen.dart';
import 'package:sApport/Views/components/info_dialog.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Signup/components/background.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/Views/Signup/Expert/components/form/expert_signup_form.dart';

/// Body of the [ExpertsSignUpScreen].
///
/// It contains the [ExpertSignUpForm] with the [FormTextField]s for gathering the
/// [Expert] profile information.
class ExpertsInfoBody extends StatefulWidget {
  /// Body of the [ExpertsSignUpScreen].
  ///
  /// It contains the [ExpertSignUpForm] with the [FormTextField]s for gathering the
  /// [Expert] profile information.
  const ExpertsInfoBody({Key? key}) : super(key: key);

  @override
  _ExpertsInfoBodyState createState() => _ExpertsInfoBodyState();
}

class _ExpertsInfoBodyState extends State<ExpertsInfoBody> {
  // View Models
  late UserViewModel userViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Expert Form
  ExpertSignUpForm expertSignUpForm = ExpertSignUpForm();

  bool nextEnabled = false;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.h),
            // Title
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50.sp, fontFamily: "Gabriola"),
            ),
            // Subtitle
            Text(
              "Sign up to increase your visibility and seize the opportunity for professional and personal growth.",
              textAlign: TextAlign.center,
              style: TextStyle(color: kPrimaryDarkColorTrasparent, fontWeight: FontWeight.bold, fontSize: 12.5.sp),
            ),
            SizedBox(height: 3.h),
            Divider(),
            SizedBox(height: 3.h),
            // Profile Image Picker
            GestureDetector(
              onTap: () => getImage(),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: kPrimaryColor,
                child: CircleAvatar(
                  radius: 67,
                  backgroundColor: kPrimaryLightColor,
                  child: ClipOval(
                    child: (expertSignUpForm.profilePhoto != null)
                        ?
                        // If the profile photo is setted, show the image
                        Image.file(File(expertSignUpForm.profilePhoto!))
                        :
                        // Otherwise show the add a photo icon with the logo
                        Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage("assets/icons/logo_circular.png"), scale: 4, opacity: 0.1),
                            ),
                            child: Center(child: Icon(Icons.add_a_photo, size: 40, color: kPrimaryColor)),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            // Form
            Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: BlocProvider(
                create: (context) => expertSignUpForm,
                child: Builder(
                  builder: (context) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: kPrimaryColor,
                        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                      ),
                      child: FormBlocListener<ExpertSignUpForm, String, String>(
                        onSubmitting: (context, state) => LoadingDialog.show(context),
                        onSuccess: (context, state) {
                          // If the address is found, show the InfoDialog for address confirmation
                          LoadingDialog.hide(context);
                          InfoDialog.show(
                            context,
                            infoType: InfoDialogType.success,
                            title: "Address found",
                            content: "${expertSignUpForm.expertAddress.address!}",
                            buttonType: ButtonType.confirm,
                            onTap: () {
                              userViewModel.createUser(expertSignUpForm);
                              routerDelegate.pushPage(name: CredentialScreen.route);
                            },
                            closeButton: true,
                          );
                        },
                        onFailure: (context, state) {
                          // If the address is not found, show the error InfoDialog
                          LoadingDialog.hide(context);
                          InfoDialog.show(context, infoType: InfoDialogType.error, content: "No address found.", buttonType: ButtonType.ok);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FormTextField(textFieldBloc: expertSignUpForm.nameText, hintText: "First name", prefixIconData: Icons.text_fields),
                            FormTextField(textFieldBloc: expertSignUpForm.surnameText, hintText: "Last name", prefixIconData: Icons.text_fields),
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
                                  prefixIcon: Icon(Icons.date_range, color: kPrimaryColor)),
                            ),
                            FormTextField(
                              textFieldBloc: expertSignUpForm.countryText,
                              hintText: "Office country",
                              prefixIconData: Icons.streetview,
                            ),
                            FormTextField(textFieldBloc: expertSignUpForm.cityText, hintText: "Office city", prefixIconData: Icons.location_city),
                            FormTextField(
                              textFieldBloc: expertSignUpForm.streetText,
                              hintText: "Office street",
                              prefixIconData: Icons.location_city,
                            ),
                            FormTextField(
                              textFieldBloc: expertSignUpForm.houseNumber,
                              hintText: "Office house number",
                              prefixIconData: Icons.house,
                              keyboardType: TextInputType.number,
                            ),
                            FormTextField(
                              textFieldBloc: expertSignUpForm.phoneNumber,
                              hintText: "Phone number",
                              prefixIconData: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Next Button
            RoundedButton(
              text: "NEXT",
              onTap: () {
                FocusScope.of(context).unfocus();
                expertSignUpForm.submit();
              },
              enabled: nextEnabled,
            ),
            SizedBox(height: 5.h),
          ],
        ),
      )),
    );
  }

  /// Get the image from the user gallery.
  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _cropImage(image.path);
    }
  }

  /// Crop the selected image with a circular cropper for the profile image.
  Future _cropImage(String imagePath) async {
    File? croppedFile = await ImageCropper.cropImage(
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
}
