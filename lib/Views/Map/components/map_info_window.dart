import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Map/components/map_body.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';

/// Custom info window used inside the [MapBody] when the user press the pin marker.
///
/// It is associated with an [expert] and it contains his/her profile photo and email.
///
/// When it is pressed, it opens the [ExpertProfileScreen].
class MapInfoWindow extends StatelessWidget {
  final Expert expert;

  /// Custom info window used inside the [MapBody] when the user press the pin marker.
  ///
  /// It is associated with an [expert] and it contains his/her profile photo and email.
  ///
  /// When it is pressed, it opens the [ExpertProfileScreen].
  const MapInfoWindow({required this.expert});

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return GestureDetector(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo
                  NetworkAvatar(img: expert.profilePhoto, radius: 20.0),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Column(
                        children: [
                          // Full Name
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  "${expert.surname} ${expert.name}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: kPrimaryColor, fontSize: 14.5.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.2.h),
                          // Email
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  expert.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: kPrimaryColor, fontSize: 10.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 10.0,
            decoration: BoxDecoration(
              color: kPrimaryDarkColor,
              border: Border.all(color: kPrimaryDarkColor),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          // Bottom Triangle
          Flexible(
            child: ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                height: 20.0,
                decoration: BoxDecoration(
                  color: kPrimaryDarkColor,
                  border: Border.all(color: kPrimaryDarkColor),
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () => routerDelegate.pushPage(name: ExpertProfileScreen.route, arguments: expert),
    );
  }
}

/// Draw of the triangle attached to the container of the info window.
class CustomClipPath extends CustomClipper<Path> {
  /// Draw of the triangle attached to the container of the info window.
  const CustomClipPath();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 4, -size.height / 3);
    path.lineTo(size.width / 2, size.height / 2.5);
    path.lineTo(size.width - size.width / 4, -size.height / 3);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
