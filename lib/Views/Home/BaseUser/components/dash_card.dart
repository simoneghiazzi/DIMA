import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Home/BaseUser/components/home_page_grid.dart';

/// Card that composes the [HomePageGrid].
///
/// It takes an [imagePath], a [text] and a [onTap] callback that it is executed
/// when the card is pressed.
class DashCard extends StatelessWidget {
  final String imagePath;
  final String text;
  final Function onTap;
  final int row;

  /// Card that composes the [HomePageGrid].
  ///
  /// It takes an [imagePath], a [text] and a [onTap] callback that it is executed
  /// when the card is pressed.
  const DashCard({Key? key, required this.imagePath, required this.text, required this.onTap, required this.row}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: row == 1 ? EdgeInsets.only(right: 1.3.w, left: 1.3.w, bottom: 2.1.h) : EdgeInsets.only(right: 1.3.w, left: 1.3.w, top: 2.1.h),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          splashColor: kPrimaryColor.withAlpha(100),
          highlightColor: Colors.transparent,
          onTap: () => onTap(),
          child: Container(
            height: (MediaQuery.of(context).orientation == Orientation.landscape) ? 25.h : 30.h,
            width: double.infinity,
            child: Card(
              elevation: 3,
              shadowColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: FittedBox(
                child: Padding(
                  padding: EdgeInsets.only(top: 3.h, bottom: 3.h, left: 4.w, right: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
                        child: Image.asset(imagePath, scale: 6),
                      ),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
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
