import 'package:flutter/material.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';

/// Button component used in the entire application.
///
/// It takes the [text] to show inside the button, the optional [prefixIcon] that is drawn
/// before the text and the optional [suffixIcon] that is drawn after the text.
class RoundedButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final Icon? prefixIcon, suffixIcon;
  final Color color, textColor;
  final bool enabled;
  final double? width;

  /// Button component used in the entire application.
  ///
  /// It takes the [text] to show inside the button, the optional [prefixIcon] that is drawn
  /// before the text and the optional [suffixIcon] that is drawn after the text.
  const RoundedButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(Size(width ?? 50.w, 6.h)),
          backgroundColor: MaterialStateProperty.all<Color>(enabled ? color : Color(0xFFD3D3D3)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          shadowColor: MaterialStateProperty.all<Color>(enabled ? kPrimaryLightColor : Color(0xFFD3D3D3)),
        ),
        onPressed: enabled ? onTap as Function() : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            prefixIcon ?? Container(),
            SizedBox(width: 5),
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textColor)),
            SizedBox(width: 5),
            suffixIcon ?? Container(),
          ],
        ),
      ),
    );
  }
}
