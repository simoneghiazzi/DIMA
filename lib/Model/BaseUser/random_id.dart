import 'dart:math';

class RandomId {
  static const String AUTO_ID_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  // Generate a random ID for retrieving a random user from the DB
  static String generate({int idLength = 28}) {
    final rand = new Random.secure();
    StringBuffer builder = new StringBuffer();
    int maxRandom = AUTO_ID_ALPHABET.length;
    for (int i = 0; i < idLength; i++) {
      builder.writeCharCode(AUTO_ID_ALPHABET.codeUnitAt((rand.nextInt(maxRandom))));
    }
    return builder.toString();
  }
}
