import 'dart:math';

class Utils {
  // It represents the alphabet of all the permitted alphanumeric values of the id into FireBase
  static const String AUTO_ID_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  /// Generate a random ID of the specified [idLength].
  static String randomId({int idLength = 28}) {
    StringBuffer idBuilder = new StringBuffer();
    for (int i = 0; i < idLength; i++) {
      idBuilder.writeCharCode(AUTO_ID_ALPHABET.codeUnitAt((Random.secure().nextInt(AUTO_ID_ALPHABET.length))));
    }
    return idBuilder.toString();
  }

  /// Returns the pair chat id of 2 users based on the [senderId] and the [peerId].
  static String pairChatId(String senderId, String peerId) {
    if (senderId.hashCode <= peerId.hashCode) {
      return "$senderId-$peerId";
    } else {
      return "$peerId-$senderId";
    }
  }
}
