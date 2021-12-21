import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';
import 'package:sizer/sizer.dart';

class MapMarker extends StatelessWidget {
  final Expert expert;

  MapMarker({required this.expert});

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NetworkAvatar(
                    img: expert.profilePhoto,
                    radius: 20.0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  (expert.surname + " " + expert.name),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: kPrimaryColor, fontSize: 17.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 0.3.h,
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  expert.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: kPrimaryColor, fontSize: 12.0),
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
      onTap: () {
        routerDelegate.pushPage(name: ExpertProfileScreen.route, arguments: expert);
      },
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 3, 0.0);
    path.lineTo(size.width / 2, size.height / 2.5);
    path.lineTo(size.width - size.width / 3, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
