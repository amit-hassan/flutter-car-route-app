import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  // Initial position (e.g., Dhaka)
  final initialPosition = const LatLng(23.8103, 90.4125);

  // Map Controller
  GoogleMapController? mapController;

  // Markers
  final markers = <Marker>{}.obs;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void addMarker(LatLng position) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
    );
    markers.add(marker);
  }

  void resetMarkers() {
    markers.clear();
  }
}
