import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class NetworkAvatar extends StatelessWidget {
  final String? img;
  final double? radius;
  const NetworkAvatar({
    Key? key,
    this.img,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(
        "assets/icons/logo_circular.png",
      ),
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          img!,
          fit: BoxFit.cover,
          width: radius! * 2,
          height: radius! * 2,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: radius! * 2,
              height: radius! * 2,
              child: CircularProgressIndicator(
                color: kPrimaryColor,
                value: loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
