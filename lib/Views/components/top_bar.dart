import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Router/app_router_delegate.dart';

/// Top bar of the base pages.
///
/// It takes the [text], the [backIcon], a list of [buttons] that are displayed
/// on the right and a [back] function that is called when the back button is pressed.
class TopBar extends StatelessWidget {
  final String text;
  final IconData backIcon;
  final List<Widget>? buttons;
  final Function? back;

  /// Top bar of the base pages.
  ///
  /// It takes a [text], a list of [buttons] that are displayed on the right and a
  /// [back] function that is called when the back button is pressed.
  const TopBar({Key? key, required this.text, this.backIcon = Icons.arrow_back_ios_new_rounded, this.buttons, this.back}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    return Container(
      color: kPrimaryColor,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: kPrimaryColor),
          height: 10.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 1.w),
              IconButton(
                icon: Icon(backIcon, color: Colors.white),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (back != null) {
                    back!();
                  }
                  routerDelegate.pop();
                },
              ),
              SizedBox(width: 1.w),
              Text(
                text,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
              ),
              Spacer(),
              ...?buttons,
            ],
          ),
        ),
      ),
    );
  }
}
