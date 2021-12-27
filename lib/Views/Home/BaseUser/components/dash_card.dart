import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Home/BaseUser/components/home_page_grid.dart';
import 'package:sizer/sizer.dart';

/// Card that composes the [HomePageGrid].
///
/// It takes an [imagePath], a [text] and a [onTap] callback that it is executed
/// when the card is pressed.
class DashCard extends StatelessWidget {
  final String imagePath;
  final String text;
  final Function onTap;

  /// Card that composes the [HomePageGrid].
  ///
  /// It takes an [imagePath], a [text] and a [onTap] callback that it is executed
  /// when the card is pressed.
  const DashCard({Key? key, required this.imagePath, required this.text, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizerUtil.deviceType == DeviceType.tablet
          ? (MediaQuery.of(context).orientation == Orientation.landscape)
              ? EdgeInsets.only(right: 25, left: 25, top: 15, bottom: 15)
              : EdgeInsets.only(right: 20, left: 20, top: 15, bottom: 15)
          : EdgeInsets.only(right: 5, left: 5, top: 15, bottom: 15),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        splashColor: kPrimaryColor.withAlpha(100),
        highlightColor: Colors.transparent,
        onTap: () => onTap(),
        child: Container(
          height: CustomSizer(30).h,
          child: Card(
            elevation: 3,
            shadowColor: kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(imagePath, scale: 5.5),
                SizedBox(height: CustomSizer(2).h),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: CustomSizer(15).sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
