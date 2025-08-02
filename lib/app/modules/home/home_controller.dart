import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_car_route_app/app/data/helpers/helpers.dart';
import 'package:flutter_car_route_app/app/data/services/services.dart';
import 'package:flutter_car_route_app/app/shared/constants/constants.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController with WidgetsBindingObserver{
  // Dependencies (Injected via Binding)
  final MapService mapService;
  final LocationService locationService;
  final RouteService routeService;
  final ConnectivityHelper connectivityHelper;
  final PermissionHelper permissionHelper;
  Timer? _gpsCheckTimer;
  final gpsStatus = Rxn<LocationStatus>();
  Rx<LocationStatus> locationStatus = LocationStatus.granted.obs;

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
    WidgetsBinding.instance.addObserver(this);
    _initServices();
  }

  Future<void> _initServices() async {
    await mapService.initCustomMarkers();
    _listenToConnectivity();
    await checkPermissionsAndGetLocation();
  }


  void _listenToConnectivity() {
    _connectivitySubscription = connectivityHelper.onConnectivityChanged.listen((isConnected) async {
      hasInternet.value = isConnected;

      if (!isConnected) {
        showNoInternetBanner();
      } else {
        hideNoInternetBanner();

        // Auto-refresh only if error previously due to no internet
        if (errorMessage.value?.contains("Internet") == true || markers.isEmpty) {
          await checkPermissionsAndGetLocation();
        }
      }
    });
  }

  void showNoInternetBanner() {
    Get.showSnackbar(
      const GetSnackBar(
        title: 'No Internet',
        message: 'Please check your connection.',
        backgroundColor: Colors.redAccent,
        duration: Duration(days: 1),
      ),
    );
  }

  void hideNoInternetBanner() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  Future<void> checkPermissionsAndGetLocation() async {
    isLoading.value = true;
    errorMessage.value = null;

    final status = await permissionHelper.checkLocationPermission();
    locationStatus.value = status;

    switch (status) {
      case LocationStatus.granted:
        final position = await Geolocator.getCurrentPosition();
        currentPosition.value = LatLng(position.latitude, position.longitude);
        _animateToPosition(currentPosition.value!);
        if (markers.length == 2) await drawRoute();
        break;

      case LocationStatus.serviceDisabled:
        errorMessage.value = AppStrings.serviceDisabled;
        break;

      case LocationStatus.permissionDenied:
      case LocationStatus.permissionPermanentlyDenied:
        errorMessage.value = AppStrings.permissionPermanentlyDenied;
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
      showError(AppStrings.noInternet);
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
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _gpsCheckTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }
  void animateToPosition(LatLng position, {double zoom = 14.0}) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom),
    ));
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermissionsAndGetLocation();
    }
  }

}
