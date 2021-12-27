import 'package:sizer/sizer.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

extension SizerExt on num {
  /// Calculates the height depending on the device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's height
  double get h => SizerUtil.deviceType == DeviceType.tablet ? this * SizerUtil.height / 140 : this * SizerUtil.height / 100;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.w -> will take 20% of the screen's width
  double get w => SizerUtil.deviceType == DeviceType.tablet ? this * SizerUtil.height / 140 : this * SizerUtil.width / 100;

  /// Calculates the sp (Scalable Pixel) depending on the device's screen size
  double get sp => SizerUtil.deviceType == DeviceType.tablet ? this * (SizerUtil.width / 3) / 140 : this * (SizerUtil.width / 3) / 100;
}
