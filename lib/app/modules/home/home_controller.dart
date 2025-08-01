import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeController extends GetxController {
  // Map
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;
  final initialPosition = const LatLng(23.8103, 90.4125);

  // Connectivity
  final isOffline = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // Location
  final currentPosition = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    _listenConnectivity();
    _checkPermissionAndFetchLocation();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _listenConnectivity() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final hasInternet = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
      isOffline.value = !hasInternet;

      // Auto refresh map markers if internet is restored
      if (!isOffline.value) {
        refreshMap();
      }
    });
  }

  Future<void> _checkPermissionAndFetchLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = LatLng(position.latitude, position.longitude);

      // Move camera to current position
      mapController?.animateCamera(
        CameraUpdate.newLatLng(currentPosition.value!),
      );
    }
  }

  void addMarker(LatLng position) {
    markers.add(Marker(
      markerId: MarkerId(position.toString()),
      position: position,
    ));
  }

  void resetMarkers() => markers.clear();

  void refreshMap() {
    // For now, just reload markers or fetch routes
    markers.refresh();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }
}
