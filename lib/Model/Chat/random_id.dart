import 'dart:math';

class RandomId {
  static const int AUTO_ID_LENGTH = 28;
  static const String AUTO_ID_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  final rand = new Random.secure();

  // Generate a random ID for retrieving a random user from the DB
  String generate() {
    StringBuffer builder = new StringBuffer();
    int maxRandom = AUTO_ID_ALPHABET.length;
    for (int i = 0; i < AUTO_ID_LENGTH; i++) {
      builder.writeCharCode(AUTO_ID_ALPHABET.codeUnitAt((rand.nextInt(maxRandom))));
    }
    return builder.toString();
  }
}
