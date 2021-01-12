import 'package:permission_handler/permission_handler.dart';

class PermissionServices
{
  PermissionHandler permissionHandler = PermissionHandler();
  Future<bool> _requestPermission(PermissionGroup permissionGroup)async
  {
    var result = await permissionHandler.requestPermissions([permissionGroup]);
    if(result[permissionGroup] == PermissionStatus.granted)
      {
        return true;
      }
    return false;
  }

}