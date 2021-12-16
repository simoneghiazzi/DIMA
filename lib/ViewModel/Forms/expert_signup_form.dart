import 'package:get_it/get_it.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Map/place.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/Services/map_service.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';

class ExpertSignUpForm extends BaseUserSignUpForm {
  // Services
  final MapService mapService = GetIt.I();

  Place expertAddress;
  String profilePhoto;

  ExpertSignUpForm() {
    // Add the field blocs to the base user signup form
    addFieldBlocs(fieldBlocs: [nameText, surnameText, birthDate, countryText, cityText, streetText, houseNumber, phoneNumber]);
  }

  /// Define the country text field bloc and add the required validator
  final countryText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  /// Define the city text field bloc and add the required validator
  final cityText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  /// Define the street text field bloc and add the required validator
  final streetText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  /// Define the house number field bloc and add the required validator
  final houseNumber = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  /// Define the phone number field bloc and add the required and phoneCorrect validators
  final phoneNumber = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.phoneCorrect,
  ]);

  @override
  User get user {
    return Expert(
      name: nameText.value,
      surname: surnameText.value,
      birthDate: birthDate.value,
      latitude: expertAddress.lat,
      longitude: expertAddress.lng,
      address: expertAddress.address,
      email: email,
      phoneNumber: phoneNumber.value,
      profilePhoto: profilePhoto,
    );
  }

  @override
  void onSubmitting() async {
    List<Place> places = await mapService.autocomplete("${countryText.value} ${cityText.value} ${streetText.value} ${houseNumber.value}");
    if (places.isNotEmpty) {
      expertAddress = await mapService.searchPlace(places.first.placeId);
      emitSuccess(canSubmitAgain: true);
    } else {
      emitFailure();
    }
  }
}
