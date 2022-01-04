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
    return Material( 
      color: Colors.transparent,     
      child: Container(
        padding: SizerUtil.deviceType == DeviceType.tablet
            ? (MediaQuery.of(context).orientation == Orientation.landscape)
                ? EdgeInsets.only(right: 25, left: 25, top: 5, bottom: 5)
                : EdgeInsets.only(right: 20, left: 20, top: 15, bottom: 15)
            : EdgeInsets.only(right: 5, left: 5, top: 15, bottom: 15),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          splashColor: kPrimaryColor.withAlpha(100),
          highlightColor: Colors.transparent,
          onTap: () => onTap(),
          child: Container(
            height: (MediaQuery.of(context).orientation == Orientation.landscape) ? CustomSizer(25).h : CustomSizer(30).h,
            width: double.infinity,
            child: Card(
              elevation: 3,
              shadowColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                        child: Image.asset(imagePath, scale: CustomSizer(1).h),
                      ),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: CustomSizer(13).sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
