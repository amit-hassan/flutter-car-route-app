import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  late GoogleMapController mapController;

  // Marker icons
  late BitmapDescriptor originIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor currentLocationIcon;


  /// Initialize custom markers
  Future<void> initCustomMarkers() async {
    originIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/markers/origin_marker.png',
    );
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/markers/destination_marker.png',
    );
    currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
  }

  /// Called when the map is created
  void onMapCreated(GoogleMapController controller, {bool isDarkMode = false, String? darkMapStyle}) {
    mapController = controller;
    mapController.setMapStyle(isDarkMode && darkMapStyle != null ? darkMapStyle : null);
  }

  Marker createOriginMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('origin'),
      position: position,
      icon: originIcon,
    );
  }

  Marker createDestinationMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('destination'),
      position: position,
      icon: destinationIcon,
    );
  }

  LatLngBounds computeBounds(LatLng point1, LatLng point2) {
    final swLat = min(point1.latitude, point2.latitude);
    final swLng = min(point1.longitude, point2.longitude);
    final neLat = max(point1.latitude, point2.latitude);
    final neLng = max(point1.longitude, point2.longitude);

    return LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
  }
}
