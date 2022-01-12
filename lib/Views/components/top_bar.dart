import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Router/app_router_delegate.dart';

/// Top bar of the base pages.
///
/// It takes the [text], the [backIcon], a list of [buttons] that are displayed
/// on the right and a [onBack] function that is called when the back button is pressed.
///
/// The [back] flag specifies if the back icon button has to be displayed or not.
class TopBar extends StatelessWidget {
  final String text;
  final double? textSize;
  final IconData backIcon;
  final List<Widget>? buttons;
  final bool back;

  /// Top bar of the base pages.
  ///
  /// It takes the [text], the [backIcon], a list of [buttons] that are displayed
  /// on the right and a [onBack] function that is called when the back button is pressed.
  ///
  /// The [back] flag specifies if the back icon button has to be displayed or not.
  const TopBar({
    Key? key,
    required this.text,
    this.textSize,
    this.backIcon = Icons.arrow_back_ios_new_rounded,
    this.buttons,
    this.back = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return Container(
      color: kPrimaryColor,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: kPrimaryColor),
          height: 9.5.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (back) ...[
                Container(
                  child: InkWell(
                    child: InkResponse(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        routerDelegate.pop();
                      },
                      child: Container(padding: EdgeInsets.only(left: 2.5.w, right: 2.5.w), child: Icon(backIcon, color: Colors.white, size: 25)),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(width: 4.w),
              ],
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(fontSize: textSize ?? 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(right: 15),
                child: Row(
                  children: [
                    if (buttons != null) ...[for (int i = 0; i < buttons!.length; i++) buttons![i]]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
