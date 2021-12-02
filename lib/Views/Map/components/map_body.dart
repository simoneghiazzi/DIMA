import 'dart:async';
import 'package:sApport/Model/BaseUser/Map/place.dart';
import 'package:sApport/Model/BaseUser/Map/place_search.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

class MapBody extends StatefulWidget {
  @override
  _MapBodyState createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  GoogleMapController mapController;
  MapViewModel mapViewModel = MapViewModel();
  Position userLocation;
  StreamSubscription<Place> subscriber;
  AppRouterDelegate routerDelegate;

  Set<Marker> _markers = Set<Marker>();

  TextEditingController txt = TextEditingController();

  //For setting the map style as specified in assets/map_style.txt
  String _mapStyle;

  //For placing custom markers on the map
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    super.initState();
    subscriber = subscribeToViewModel();
    mapViewModel.uploadPosition();
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    //For setting the map style
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    //Icon used for custom markers
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1, size: Size(2, 2)), 'assets/icons/pin.png').then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Center(
          child: StreamBuilder<Position>(
              stream: mapViewModel.position,
              builder: (context, snapshot) {
                return snapshot.data == null
                    ? Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          FutureBuilder(
                              future: mapViewModel.getMarkers(),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                                      zoom: 16,
                                    ),
                                    compassEnabled: true,
                                    mapToolbarEnabled: false,
                                    myLocationButtonEnabled: false,
                                    myLocationEnabled: true,
                                    zoomControlsEnabled: false,
                                    onMapCreated: (GoogleMapController controller) {
                                      mapViewModel.mapController.complete(controller);
                                      removeMarkers();
                                      mapController = controller;
                                    },
                                  );
                                } else {
                                  for (var doc in snap.data.docs) {
                                    if (doc.data() != null) {
                                      Expert expert = Expert();
                                      expert.setFromDocument(doc);
                                      _markers.add(Marker(
                                          markerId: MarkerId(
                                              expert.getData()['surname'] + expert.getData()['lat'].toString() + expert.getData()['lng'].toString()),
                                          position: LatLng(expert.getData()['lat'], expert.getData()['lng']),
                                          icon: pinLocationIcon,
                                          infoWindow: InfoWindow(
                                              onTap: () {
                                                routerDelegate.pushPage(name: ExpertProfileScreen.route, arguments: expert);
                                              },
                                              title: expert.getData()['surname'] +
                                                  " " +
                                                  expert.getData()['name'] +
                                                  " (" +
                                                  expert.getData()['phoneNumber'] +
                                                  ")",
                                              snippet: expert.getData()['email'])));
                                    }
                                  }
                                  return GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                                      zoom: 16,
                                    ),
                                    compassEnabled: true,
                                    mapToolbarEnabled: false,
                                    markers: _markers,
                                    myLocationButtonEnabled: false,
                                    myLocationEnabled: true,
                                    zoomControlsEnabled: false,
                                    onMapCreated: (GoogleMapController controller) {
                                      mapViewModel.mapController.complete(controller);
                                      removeMarkers();
                                      mapController = controller;
                                    },
                                  );
                                }
                              }),
                          Positioned(
                            bottom: 40,
                            right: 20,
                            child: FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                                  target: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                                  zoom: 16,
                                )));
                              },
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              backgroundColor: Colors.white10,
                              child: const Icon(Icons.my_location, size: 40.0),
                            ),
                          ),
                        ],
                      );
              })),
      Positioned(
          top: 60,
          right: 20,
          left: 20,
          child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0), boxShadow: [
                BoxShadow(
                  color: kPrimaryDarkColor.withOpacity(0.3),
                  spreadRadius: 4,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ]),
              child: Row(children: <Widget>[
                IconButton(
                  splashColor: Colors.grey,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: kPrimaryColor,
                  ),
                  onPressed: () {
                    routerDelegate.pop();
                  },
                ),
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: kPrimaryColor,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                    controller: txt,
                    decoration: InputDecoration(
                        fillColor: kPrimaryColor,
                        border: InputBorder.none,
                        hintText: "Search place",
                        suffixIcon: Icon(
                          Icons.search,
                          color: kPrimaryColor,
                        )),
                    onChanged: (value) => mapViewModel.searchPlaces(value),
                  ),
                ),
              ]))),
      StreamBuilder<List<PlaceSearch>>(
          stream: mapViewModel.places,
          builder: (context, snapshot) {
            return (snapshot.data == null || snapshot.data.length == 0)
                ? Container(width: 0.0, height: 0.0)
                : Column(children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(color: Colors.black.withOpacity(.6), backgroundBlendMode: BlendMode.darken),
                            child: ListView.builder(
                                padding: EdgeInsets.only(top: 100),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      contentPadding: EdgeInsets.only(top: 10, left: 15, right: 5),
                                      title: Text(
                                        snapshot.data[index].description,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        mapViewModel.setSelectedLocation(snapshot.data[index].placeId);
                                        txt.text = snapshot.data[index].description;
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      });
                                })))
                  ]);
          }),
    ]);
  }

  Future<void> removeMarkers() async {
    final GoogleMapController controller = await mapViewModel.mapController.future;
    controller.setMapStyle(_mapStyle);
  }

  StreamSubscription<Place> subscribeToViewModel() {
    return mapViewModel.location.listen((place) {
      if (place != null) {
        _goToPlace(place);
      } else {
        print("Error, search again");
      }
    });
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await mapViewModel.mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(place.geometry.location.lat, place.geometry.location.lng), zoom: 15),
      ),
    );
    mapViewModel.searchPlaces("");
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
