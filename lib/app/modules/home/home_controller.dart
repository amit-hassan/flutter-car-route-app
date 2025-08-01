import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../shared/constants/map_styles.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {
  // Google Map
  late GoogleMapController mapController;
  final initialPosition = const LatLng(23.8103, 90.4125);

  // Markers
  final markers = <Marker>[].obs;
  late BitmapDescriptor originIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor currentLocationIcon;

  LatLng? originLatLng;
  LatLng? destinationLatLng;
  final currentPosition = Rxn<LatLng>();

  // Connectivity
  final isOffline = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // Location Stream
  StreamSubscription<Position>? _locationSub;

  @override
  void onInit() {
    super.onInit();
    _listenConnectivity();
    _loadCustomMarkers();
    _checkPermissionAndFetchLocation();
    _startLiveLocationTracking();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _applyMapTheme();
  }

  void _applyMapTheme() {
    final isDarkMode = Get.isDarkMode;
    if (isDarkMode) {
      mapController.setMapStyle(darkMapStyle);
    } else {
      mapController.setMapStyle(null);
    }
  }

  /// Load custom marker icons
  Future<void> _loadCustomMarkers() async {
    originIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      'assets/markers/origin_marker.png',
    );

    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      'assets/markers/destination_marker.png',
    );

    currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
  }

  /// Listen to connectivity changes
  void _listenConnectivity() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final hasInternet = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
      isOffline.value = !hasInternet;

      if (!isOffline.value) {
        refreshMap();
      }
    });
  }

  /// Request permission & fetch initial location
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
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition.value!, 16),
      );

      _updateMarkers();
    }
  }

  /// Start live location tracking
  void _startLiveLocationTracking() {
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    ).listen((Position position) {
      currentPosition.value = LatLng(position.latitude, position.longitude);
      _updateMarkers();
    });
  }

  /// Handle user tapping on map
  void addMarker(LatLng position) {
    if (originLatLng == null) {
      originLatLng = position;
    } else if (destinationLatLng == null) {
      destinationLatLng = position;
      animateToBounds();
    } else {
      // Reset if 3rd tap
      originLatLng = position;
      destinationLatLng = null;
    }
    _updateMarkers();
  }

  /// Update all markers (origin, destination, current location)
  void _updateMarkers() {
    final newMarkers = <Marker>[];

    // Current location
    if (currentPosition.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentPosition.value!,
          icon: currentLocationIcon,
        ),
      );
    }

    // Origin
    if (originLatLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: originLatLng!,
          icon: originIcon,
        ),
      );
    }

    // Destination
    if (destinationLatLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng!,
          icon: destinationIcon,
        ),
      );
    }

    markers.value = newMarkers;
  }

  /// Animate camera to fit both origin & destination
  void animateToBounds() {
    if (originLatLng == null || destinationLatLng == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        originLatLng!.latitude < destinationLatLng!.latitude
            ? originLatLng!.latitude
            : destinationLatLng!.latitude,
        originLatLng!.longitude < destinationLatLng!.longitude
            ? originLatLng!.longitude
            : destinationLatLng!.longitude,
      ),
      northeast: LatLng(
        originLatLng!.latitude > destinationLatLng!.latitude
            ? originLatLng!.latitude
            : destinationLatLng!.latitude,
        originLatLng!.longitude > destinationLatLng!.longitude
            ? originLatLng!.longitude
            : destinationLatLng!.longitude,
      ),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  /// Reset markers
  void resetMarkers() {
    originLatLng = null;
    destinationLatLng = null;
    _updateMarkers();
  }

  /// Force refresh (called on internet restore)
  void refreshMap() {
    _updateMarkers();
  }

  /// Center map on user
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
    _locationSub?.cancel();
    super.onClose();
  }
}
