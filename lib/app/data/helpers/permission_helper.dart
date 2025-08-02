import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationStatus { granted, serviceDisabled, permissionDenied, permissionPermanentlyDenied}

class PermissionHelper {
  Future<LocationStatus> checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      await Geolocator.openLocationSettings();
      return LocationStatus.serviceDisabled;
    }

    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isGranted) {
        return LocationStatus.granted;
      }
    }

    if (status.isGranted) {
      return LocationStatus.granted;
    } else if (status.isPermanentlyDenied) {
      // Prompt user to go to app settings
      await openAppSettings();
      return LocationStatus.permissionPermanentlyDenied;
    } else {
      return LocationStatus.permissionDenied;
    }
  }
}