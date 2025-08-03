import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_car_route_app/app/data/helpers/helpers.dart';
import 'package:flutter_car_route_app/app/data/services/services.dart';
import 'package:flutter_car_route_app/app/shared/constants/constants.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  // Dependencies
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

  // Reactive states
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final gpsStatus = Rx<LocationStatus>(LocationStatus.granted);
  final hasInternet = true.obs;

  // Map + Position state
  GoogleMapController? mapController;
  final currentPosition = Rxn<LatLng>();
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  // Route Info
  final distance = RxnString();
  final duration = RxnString();

  // Place names
  final originName = RxnString();
  final destinationName = RxnString();

  StreamSubscription? _connectivitySubscription;

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
        if (errorMessage.value?.contains("Internet") == true || markers.isEmpty) {
          await checkPermissionsAndGetLocation();
        }
      }
    });
  }

  Future<void> checkPermissionsAndGetLocation() async {
    isLoading.value = true;
    errorMessage.value = null;

    final status = await permissionHelper.checkLocationPermission();
    switch (status) {
      case LocationStatus.granted:
        final position = await Geolocator.getCurrentPosition();
        currentPosition.value = LatLng(position.latitude, position.longitude);
        animateToPosition(currentPosition.value!);
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

  void onMapTap(LatLng position) async {
    if (markers.length >= 2) clearRoute();

    if (markers.isEmpty) {
      // Origin
      final marker = mapService.createOriginMarker(position);
      markers.add(marker);
      originName.value = await mapService.getAddressFromLatLng(position);
    } else {
      // Destination
      final marker = mapService.createDestinationMarker(position);
      markers.add(marker);
      destinationName.value = await mapService.getAddressFromLatLng(position);
      await drawRoute();
    }
  }

  Future<void> drawRoute() async {
    if (markers.length < 2) return;
    if (!await connectivityHelper.hasConnection()) {
      showError(AppStrings.noInternet);
      return;
    }

    isLoading.value = true;
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
    originName.value = null;
    destinationName.value = null;
    distance.value = null;
    duration.value = null;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;

    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;

    mapService.onMapCreated(controller, isDarkMode: isDark, darkMapStyle: darkMapStyle);

    if (currentPosition.value != null) {
      animateToPosition(currentPosition.value!);
    }
  }


  void animateToPosition(LatLng position, {double zoom = 14.0}) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom),
    ));
  }

  void showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  void showNoInternetBanner() {
    Get.showSnackbar(const GetSnackBar(
      title: 'No Internet',
      message: 'Please check your connection.',
      backgroundColor: Colors.redAccent,
      duration: Duration(days: 1),
    ));
  }

  void hideNoInternetBanner() {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) checkPermissionsAndGetLocation();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }
}

