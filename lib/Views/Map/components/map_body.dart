import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:sApport/Model/BaseUser/Map/geometry.dart';
import 'package:sApport/Model/BaseUser/Map/location.dart';
import 'package:sApport/Model/BaseUser/Map/place.dart';
import 'package:sApport/Model/BaseUser/Map/place_search.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Map/components/map_marker.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
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
  Completer<GoogleMapController> completer = Completer();
  GoogleMapController mapController;
  MapViewModel mapViewModel;
  Position userLocation;
  StreamSubscription<Place> subscriber;
  AppRouterDelegate routerDelegate;
  var _searching = StreamController<bool>.broadcast();
  var isPositionSearched = false;

  Set<Marker> _markers = Set<Marker>();

  TextEditingController textController = TextEditingController();

  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  //For setting the map style as specified in assets/map_style.txt
  String _mapStyle;

  //For placing custom markers on the map
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    subscriber = subscribeToViewModel();
    // For setting the map style
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    // Icon used for custom markers
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1, size: Size(2, 2)), 'assets/icons/pin.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    getMarkers();

    if (!mapViewModel.positionPermission.isGranted) {
      mapViewModel.askPermission().then((permission) {
        if (permission) {
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(mapViewModel.positionPermission.isPermanentlyDenied
                ? 'You cannot access your current position. Enable the location permission in the device settings.'
                : 'You cannot access your current position.'),
            duration: const Duration(seconds: 5),
          ));
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      if (mapViewModel.positionPermission.isGranted) ...[
        Center(
          child: FutureBuilder<Position>(
              future: mapViewModel.uploadPosition(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildMap(lat: snapshot.data.latitude, lng: snapshot.data.longitude);
                } else {
                  return LoadingDialog().widget(context);
                }
              }),
        ),
        // Button My Position
        Align(
          alignment: Alignment.lerp(Alignment.bottomRight, Alignment.center, 0.1),
          child: FloatingActionButton(
            onPressed: () async {
              var pos = await mapViewModel.uploadPosition();
              _goToPlace(Place(geometry: Geometry(location: Location(lat: pos.latitude, lng: pos.longitude))));
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: kPrimaryColor,
            child: const Icon(
              Icons.my_location,
              size: 30.0,
              color: Colors.white,
            ),
          ),
        ),
      ] else ...[
        buildMap(),
      ],
      Positioned(
        top: 50,
        right: 20,
        left: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: kPrimaryDarkColor.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Row(children: <Widget>[
            IconButton(
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
                textAlignVertical: TextAlignVertical.center,
                cursorColor: kPrimaryColor,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                controller: textController,
                decoration: InputDecoration(
                    fillColor: kPrimaryColor,
                    border: InputBorder.none,
                    hintText: "Search place",
                    suffixIcon: Icon(
                      Icons.search_rounded,
                      color: kPrimaryColor,
                    )),
                onTap: () {
                  setSearch(true);
                  if (isPositionSearched) {
                    textController.clear();
                    isPositionSearched = false;
                  }
                },
                onChanged: (value) => mapViewModel.searchPlaces(value),
              ),
            ),
          ]),
        ),
      ),
      StreamBuilder(
        stream: searching,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return Stack(children: [
              Positioned(
                top: 50,
                right: 20,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                  child: Row(children: <Widget>[
                    IconButton(
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
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        controller: textController,
                        decoration: InputDecoration(
                            fillColor: kPrimaryColor,
                            border: InputBorder.none,
                            hintText: "Search place",
                            suffixIcon: Icon(
                              Icons.search_rounded,
                              color: kPrimaryColor,
                            )),
                        onChanged: (value) => mapViewModel.searchPlaces(value),
                      ),
                    ),
                  ]),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryDarkColor.withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                margin: EdgeInsets.only(top: 105, left: 20, right: 20),
                child: StreamBuilder<List<PlaceSearch>>(
                    stream: mapViewModel.places,
                    builder: (context, snapshot) {
                      return (snapshot.data == null || snapshot.data.length == 0)
                          ? Container(width: 0.0, height: 0.0)
                          : ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) => Divider(height: 1, color: kPrimaryLightColor),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 5),
                                    title: Text(
                                      snapshot.data[index].description,
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                    onTap: () {
                                      isPositionSearched = true;
                                      setSearch(false);
                                      mapViewModel.setSelectedLocation(snapshot.data[index].placeId);
                                      textController.text = snapshot.data[index].description;
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    });
                              });
                    }),
              ),
            ]);
          } else {
            return Container();
          }
        },
      ),
      CustomInfoWindow(
        controller: _customInfoWindowController,
        height: 80,
        width: 200,
      ),
    ]);
  }

  Stream<bool> get searching => _searching.stream;

  void setSearch(bool isSearching) {
    _searching.add(isSearching);
  }

  Future<void> setMapStyle() async {
    final GoogleMapController controller = await completer.future;
    controller.setMapStyle(_mapStyle);
  }

  void getMarkers() {
    mapViewModel.getMarkers().then((snapshot) {
      for (var doc in snapshot.docs) {
        Expert expert = Expert();
        expert.setFromDocument(doc);
        _markers.add(
          Marker(
            markerId: MarkerId(expert.getData()['surname'] + expert.getData()['lat'].toString() + expert.getData()['lng'].toString()),
            position: LatLng(expert.getData()['lat'], expert.getData()['lng']),
            icon: pinLocationIcon,
            onTap: () {
              _customInfoWindowController.addInfoWindow(
                MapMarker(expert: expert),
                LatLng(expert.getData()['lat'], expert.getData()['lng']),
              );
            },
          ),
        );
      }
      setState(() {});
    });
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
    final GoogleMapController controller = await completer.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(place.geometry.location.lat, place.geometry.location.lng), zoom: 15),
      ),
    );
    mapViewModel.searchPlaces("");
  }

  Widget buildMap({lat = 45.478195, lng = 9.2256787}) {
    return GoogleMap(
      onTap: (position) {
        setSearch(false);
        _customInfoWindowController.hideInfoWindow();
      },
      onCameraMove: (position) {
        setSearch(false);
        _customInfoWindowController.onCameraMove();
      },
      onMapCreated: (GoogleMapController controller) async {
        if (!completer.isCompleted) {
          completer.complete(controller);
        }
        setMapStyle();
        mapController = controller;
        _customInfoWindowController.googleMapController = controller;
      },
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15,
      ),
      compassEnabled: true,
      mapToolbarEnabled: false,
      markers: _markers,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  @override
  void dispose() {
    subscriber.cancel();
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
