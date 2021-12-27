import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/constants.dart';

/// It is used for showing the profile photo of an expert user.
///
/// It takes the [img] to show and the [radius] of the circle avatar.
///
/// It handles the loading of the image by showing the logo and a circular progress indicator.
class NetworkAvatar extends StatelessWidget {
  final String img;
  final double radius;

  /// It is used for showing the profile photo of an expert user.
  ///
  /// It takes the [img] to show and the [radius] of the circle avatar.
  ///
  /// It handles the loading of the image by showing the logo and a circular progress indicator.
  const NetworkAvatar({Key? key, required this.img, required this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage("assets/icons/logo_circular.png"),
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          img,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: CircularProgressIndicator(
                color: kPrimaryColor,
                value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
