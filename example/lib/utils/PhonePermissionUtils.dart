import 'package:permission_handler/permission_handler.dart';

class PhonePermissionUtils {
  // 申请存储权限
  static Future<bool> checkPermission() async {

    Map<Permission, PermissionStatus> permisasasssions = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
    ].request();

    return true;
  }

}
