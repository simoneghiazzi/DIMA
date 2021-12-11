import 'package:sApport/Model/BaseUser/Map/place.dart';
import 'package:sApport/Model/BaseUser/Map/place_search.dart';
import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ExpertSignUpForm extends BaseUserSignUpForm {
  // Services
  final MapViewModel mapViewModel = MapViewModel();

  String infoAddress;
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
  Map<String, Object> get data {
    return {
      "name": nameText.value,
      "surname": surnameText.value,
      "birthDate": birthDate.value,
      "lat": expertAddress.geometry.location.lat,
      "lng": expertAddress.geometry.location.lng,
      "address": infoAddress,
      "email": email,
      "phoneNumber": phoneNumber.value,
      "profilePhoto": profilePhoto,
    };
  }

  @override
  void onSubmitting() async {
    List<PlaceSearch> address =
        await mapViewModel.searchPlaceSubscription("${countryText.value} ${cityText.value} ${streetText.value} ${houseNumber.value}");
    if (address.isNotEmpty) {
      infoAddress = address.first.description;
      expertAddress = await mapViewModel.getExpertLocation(address.first.placeId);
      emitSuccess(canSubmitAgain: true);
    } else {
      emitFailure();
    }
  }
}
