import 'package:sApport/Model/BaseUser/Map/place.dart';
import 'package:sApport/Model/BaseUser/Map/place_search.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ExpertSignUpForm extends BaseUserSignUpForm {
  final MapViewModel mapViewModel = MapViewModel();
  String infoAddress;
  Place expertAddress;
  String profilePhoto;

  final countryText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final cityText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final streetText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final addressNumberText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final phoneNumberText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.phoneCorrect,
  ]);

  ExpertSignUpForm() {
    addFieldBlocs(fieldBlocs: [
      nameText,
      surnameText,
      birthDateTime,
      countryText,
      cityText,
      streetText,
      addressNumberText,
      phoneNumberText
    ]);
  }

  @override
  Map get values {
    return {
      'name': nameText.value,
      'surname': surnameText.value,
      'birthDate': birthDateTime.value,
      'lat': expertAddress.geometry.location.lat,
      'lng': expertAddress.geometry.location.lng,
      'address': infoAddress,
      'email': email,
      'phoneNumber': phoneNumberText.value,
      'profilePhoto': profilePhoto,
    };
  }

  @override
  void onSubmitting() async {
    List<PlaceSearch> address = await mapViewModel.searchPlaceSubscription(
        countryText.value +
            " " +
            cityText.value +
            " " +
            streetText.value +
            " " +
            addressNumberText.value);
    if (address.isNotEmpty) {
      infoAddress = address.first.description;
      expertAddress =
          await mapViewModel.getExpertLocation(address.first.placeId);
      emitSuccess(canSubmitAgain: true);
    } else {
      emitFailure();
    }
  }
}
