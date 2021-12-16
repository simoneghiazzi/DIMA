class Place {
  final double lat;
  final double lng;
  final String placeId;
  final String address;

  Place({this.lat, this.lng, this.placeId, this.address});

  /// Returns a Place intance with the [description] and [placeId] variables setted
  /// from the [jsonResponse] of the autocomplete Google Map API.
  factory Place.fromAutocompleteJson(Map<String, dynamic> jsonResponse) {
    return Place(
      address: jsonResponse["description"],
      placeId: jsonResponse["place_id"],
    );
  }

  /// Returns a Place intance with the [lat], [lng] and [address] variables setted
  /// from the [jsonResponse] of the search place Google Map API.
  factory Place.fromSearchJson(Map<String, dynamic> jsonResponse) {
    return Place(
      lat: jsonResponse["geometry"]["location"]["lat"],
      lng: jsonResponse["geometry"]["location"]["lng"],
      address: jsonResponse["formatted_address"],
    );
  }
}
