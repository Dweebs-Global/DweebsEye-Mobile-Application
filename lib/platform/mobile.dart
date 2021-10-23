import 'myplatform.dart';
import 'dart:io';

class PlatformUtil {
  static MyPlatform myPlatform() {
    if (Platform.isAndroid) return MyPlatform.ANDROID;
    if (Platform.isIOS) return MyPlatform.IOS;
    return null;
  }
}
