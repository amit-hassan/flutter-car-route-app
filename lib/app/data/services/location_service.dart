import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LocationService {
  StreamSubscription<Position>? _locationSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Stream user location
  Stream<Position> getLocationStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    final permission = await _checkPermission();
    if (!permission) return null;
    return Geolocator.getCurrentPosition();
  }

  /// Request location permission if needed
  Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Listen to connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  void dispose() {
    _locationSub?.cancel();
    _connectivitySub?.cancel();
  }
}
