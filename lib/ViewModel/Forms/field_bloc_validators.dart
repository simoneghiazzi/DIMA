class BlocValidatorsErrors {
  static const String phoneNotCorrect = "Phone number not valid";

  static const String underAge = "You must be of legal age";
}

class BlocValidators {
  /// Check if the [value], that is the age, is not null, not empty or less than 18 years old.
  ///
  /// Returns `null` if is valid.
  ///
  /// Returns [BlocValidatorsErrors.underAge] if is not valid.
  static String? underage(dynamic value) {
    DateTime adultHood = new DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
    if (value == null || !(value is DateTime && value.isAfter(adultHood))) {
      return null;
    }
    return BlocValidatorsErrors.underAge;
  }

  /// Check if the [string] is a correct phone number
  /// if [string] is not null and not empty.
  ///
  /// Returns `null` if is valid.
  ///
  /// Returns [FieldBlocValidatorsErrors.phoneCorrect]
  /// if is not valid.
  static String? phoneCorrect(String? string) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (string == null || string.isEmpty || regExp.hasMatch(string)) {
      return null;
    }
    return BlocValidatorsErrors.phoneNotCorrect;
  }
}
