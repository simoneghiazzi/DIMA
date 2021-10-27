class InputValidator {
static String title(String value) {
    if (value.isEmpty) {
      return 'C\'mon, give me a headline!';
    }
    return null;
  }
  static String content(String value) {
    if (value.isEmpty) {
      return 'Hey! You haven\'t told me anything yet!';
    }
    return null;
  }
}