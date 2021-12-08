import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Expert/expert.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';

class MapMarker extends StatelessWidget {
  final Expert expert;

  MapMarker({@required this.expert});

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
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  NetworkAvatar(
                    img: expert.profilePhoto,
                    radius: 20.0,
                  ),
                  Column(
                    children: [
                      Text(
                        (expert.surname + " " + expert.name),
                        overflow: TextOverflow.clip,
                        style: TextStyle(color: kPrimaryColor, fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        expert.phoneNumber,
                        overflow: TextOverflow.clip,
                        style: TextStyle(color: kPrimaryColor, fontSize: 14.0),
                      ),
                      Text(
                        expert.email,
                        overflow: TextOverflow.clip,
                        style: TextStyle(color: kPrimaryColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 10.0,
            decoration: BoxDecoration(
              color: kPrimaryDarkColor,
              border: Border.all(
                color: kPrimaryDarkColor,
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          Flexible(
            child: ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                height: 40.0,
                color: kPrimaryDarkColor,
              ),
            ),
          )
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
    path.lineTo(size.width / 2, size.height / 3);
    path.lineTo(size.width - size.width / 3, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
