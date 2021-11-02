class InputValidator {
  static bool title(String value) {
    if (value.isEmpty) {
      return false;
    }
    return true;
  }

  static bool content(String value) {
    if (value.isEmpty) {
      return false;
    }
    return true;
  }
}
