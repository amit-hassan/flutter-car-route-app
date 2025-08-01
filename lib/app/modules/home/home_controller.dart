import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../shared/constants/map_styles.dart';

class HomeController extends GetxController {
  // Map
  late GoogleMapController mapController;
  late BitmapDescriptor originIcon;
  late BitmapDescriptor destinationIcon;
  final markers = <Marker>{}.obs;
  final initialPosition = const LatLng(23.8103, 90.4125);
  final originLatLng = Rxn<LatLng>();
  final destinationLatLng = Rxn<LatLng>();


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
    _loadCustomMarkers();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _applyMapTheme();
  }

  void _applyMapTheme() async {
    final isDarkMode = Get.isDarkMode;
    if (isDarkMode) {
      mapController.setMapStyle(darkMapStyle);
    } else {
      mapController.setMapStyle(null);
    }
  }

  Future<void> _loadCustomMarkers() async {
    originIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/origin_marker.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/destination_marker.png');
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
    if (originLatLng.value == null) {
      originLatLng.value = position;
      markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: position,
        icon: originIcon,
      ));
    } else if (destinationLatLng.value == null) {
      destinationLatLng.value = position;
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: position,
        icon: destinationIcon,
      ));
      animateToBounds(); // Fit camera to both markers
    } else {
      // Reset and start fresh
      resetMarkers();
      originLatLng.value = position;
      markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: position,
        icon: originIcon,
      ));
      destinationLatLng.value = null;
    }
  }


  void animateToBounds() {
    if (markers.length < 2) return;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      minLat = marker.position.latitude < minLat ? marker.position.latitude : minLat;
      maxLat = marker.position.latitude > maxLat ? marker.position.latitude : maxLat;
      minLng = marker.position.longitude < minLng ? marker.position.longitude : minLng;
      maxLng = marker.position.longitude > maxLng ? marker.position.longitude : maxLng;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void resetMarkers() => markers.clear();

  void refreshMap() {
    // For now, just reload markers or fetch routes
    markers.refresh();
  }

  void centerOnUser() {
    if (currentPosition.value != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition.value!, 16),
      );
    }
  }


  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }
}
