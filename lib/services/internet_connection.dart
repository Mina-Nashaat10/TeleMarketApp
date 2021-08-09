import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class InternetConnection {
  static Future<bool> internetAvailable(Connectivity connectivity) async {
    ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (e) {
      print(e.toString());
      return false;
    }
  }
}
