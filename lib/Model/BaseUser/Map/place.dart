class Place {
  final double lat;
  final double lng;
  final String placeId;
  final String address;

  Place({this.lat, this.lng, this.placeId, this.address});

  factory Place.fromAutocompleteJson(Map<String, dynamic> parsedJson) {
    return Place(
      address: parsedJson["description"],
      placeId: parsedJson["place_id"],
    );
  }

  factory Place.fromSearchJson(Map<String, dynamic> parsedJson) {
    return Place(
      lat: parsedJson["geometry"]["location"]["lat"],
      lng: parsedJson["geometry"]["location"]["lng"],
      address: parsedJson["formatted_address"],
    );
  }
}
