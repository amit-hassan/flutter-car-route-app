import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_car_route_app/app/data/helpers/helpers.dart';
import 'package:flutter_car_route_app/app/data/services/services.dart';
import 'package:flutter_car_route_app/app/shared/constants/constants.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {
  // Dependencies (Injected via Binding)
  final MapService mapService;
  final LocationService locationService;
  final RouteService routeService;
  final ConnectivityHelper connectivityHelper;
  final PermissionHelper permissionHelper;

  HomeController({
    required this.mapService,
    required this.locationService,
    required this.routeService,
    required this.connectivityHelper,
    required this.permissionHelper,
  });

  // Reactive State Variables (The Single Source of Truth)
  final isOffline = false.obs;
  final origin = Rxn<LatLng>();
  final destination = Rxn<LatLng>();


  StreamSubscription<Position>? _locationSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static const LatLng initialPosition = LatLng(23.8103, 90.4125); // Default position

  // UI State Management
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasInternet = true.obs;
  StreamSubscription? _connectivitySubscription;

  // Map State
  GoogleMapController? mapController;
  final Rxn<LatLng> currentPosition = Rxn();
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  // Route Info State
  final RxnString distance = RxnString();
  final RxnString duration = RxnString();

  @override
  void onInit() {
    super.onInit();
    _initServices();
  }

  Future<void> _initServices() async {
    await mapService.initCustomMarkers();
    _listenToConnectivity();
    await _checkPermissionsAndGetLocation();
  }


  void _listenToConnectivity() {
    _connectivitySubscription = connectivityHelper.onConnectivityChanged.listen((isConnected) {
      hasInternet.value = isConnected;
      if (!isConnected) {
        showError('No Internet Connection');
      }
    });
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    isLoading.value = true;
    errorMessage.value = null;

    final status = await permissionHelper.checkLocationPermission();
    switch (status) {
      case LocationStatus.granted:
        final position = await Geolocator.getCurrentPosition();
        currentPosition.value = LatLng(position.latitude, position.longitude);
        _animateToPosition(currentPosition.value!);
        break;
      case LocationStatus.serviceDisabled:
        errorMessage.value = 'Please enable GPS/Location Services.';
        break;
      case LocationStatus.permissionDenied:
        errorMessage.value = 'Location permission is required to use this feature.';
        break;
      case LocationStatus.permissionPermanentlyDenied:
        errorMessage.value = 'Location permission is permanently denied. Please enable it in app settings.';
        break;
    }
    isLoading.value = false;
  }

  void onMapTap(LatLng position) {
    if (markers.length >= 2) {
      clearRoute();
    }
    _addMarker(position);

    if (markers.length == 2) {
      drawRoute();
    }
  }

  void _addMarker(LatLng position) {
    final id = 'marker_id_${markers.length}';
    final label = markers.isEmpty ? 'Origin' : 'Destination';
    final hue = markers.isEmpty ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed;

    markers.add(Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
    ));
  }

  Future<void> drawRoute() async {
    if (markers.length < 2) return;
    if (!await connectivityHelper.hasConnection()) {
      showError('No Internet Connection');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final origin = markers.first.position;
    final destination = markers.last.position;

    try {
      final directions = await routeService.getDirections(
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
      );

      distance.value = directions.distance;
      duration.value = directions.duration;

      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blueAccent,
        width: 5,
        points: directions.polylinePoints,
      ));
    } catch (e) {
      showError(e.toString());
      // On error, remove the last added marker to allow re-selection
      markers.remove(markers.last);
    } finally {
      isLoading.value = false;
    }
  }

  void clearRoute() {
    markers.clear();
    polylines.clear();
    distance.value = null;
    duration.value = null;
  }

  void showError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentPosition.value != null) {
      _animateToPosition(currentPosition.value!);
    }
  }

  void _animateToPosition(LatLng position, {double zoom = 14.0}) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom),
    ));
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  // After (Public)
  void animateToPosition(LatLng position, {double zoom = 14.0}) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom),
    ));
  }


}
