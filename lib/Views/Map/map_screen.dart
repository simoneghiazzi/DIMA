import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Map/components/map_body.dart';
import 'package:sApport/Views/components/vertical_split_view.dart';
import 'package:sApport/Views/Profile/components/expert_profile_body.dart';

/// Page of the map.
///
/// It shows the [MapBody] that contains all the experts inside [GoogleMap].
///
/// It contains the [OrientationBuilder] that checks the orientation of the device and
/// rebuilds the page when the orientation changes. If it is:
/// - portrait: it displays the [MapBody].
/// - landscape: it uses the [VerticalSplitView] for displayng the [MapBody] on the left and the
/// [ExpertProfileBody] (if it is not null) on the right, otherwise it sets the ratio = 1 and it shows
/// only the [MapBody].
///
/// It subscribes to the map view model currentExpert value notifier in order to rebuild the right hand side of the page
/// when a new current expert is selected.
class MapScreen extends StatefulWidget {
  /// Route of the page used by the Navigator.
  static const route = "/mapScreen";

  /// Page of the map.
  ///
  /// It shows the [MapBody] that contains all the experts inside [GoogleMap].
  ///
  /// It contains the [OrientationBuilder] that checks the orientation of the device and
  /// rebuilds the page when the orientation changes. If it is:
  /// - portrait: it displays the [MapBody].
  /// - landscape: it uses the [VerticalSplitView] for displayng the [MapBody] on the left and the
  /// [ExpertProfileBody] (if it is not null) on the right, otherwise it sets the ratio = 1 and it shows
  /// only the [MapBody].
  ///
  /// It subscribes to the map view model currentExpert value notifier in order to rebuild the right hand side of the page
  /// when a new current expert is selected.
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // View Models
  late MapViewModel mapViewModel;

  @override
  void initState() {
    mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            // If the orientation is protrait, shows the MapBody
            return MapBody();
          } else {
            // If the orientation is landscape, shows the ValueListenableBuilder listener that builds the VerticalSplitView
            // with the MapBody on the left and, if the current expert is not null, the ExpertProfileBody on the right,
            // otherwise sets the ration = 1 (it shows only the left widget).
            return ValueListenableBuilder(
              valueListenable: mapViewModel.currentExpert,
              builder: (context, Expert? currentExpert, child) {
                var _ratio = mapViewModel.currentExpert.value != null ? 0.50 : 1.0;
                return VerticalSplitView(
                  left: MapBody(),
                  right: mapViewModel.currentExpert.value != null ? ExpertProfileBody() : Container(),
                  ratio: _ratio,
                  dividerWidth: 2.0,
                  dividerColor: kPrimaryGreyColor,
                );
              },
            );
          }
        },
      ),
    );
  }
}
