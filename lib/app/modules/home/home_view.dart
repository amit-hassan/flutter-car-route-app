import 'package:flutter/material.dart';
import 'package:flutter_car_route_app/app/data/helpers/helpers.dart';
import 'package:flutter_car_route_app/app/shared/constants/constants.dart';
import 'package:flutter_car_route_app/app/shared/widgets/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Full screen error/loading for initial setup
        if (controller.isLoading.value && controller.currentPosition.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        // Location service is disabled
        if (controller.gpsStatus.value == LocationStatus.serviceDisabled) {
          return FullScreenErrorMessage(
            message: AppStrings.enableGpsMessage,
            buttonText: AppStrings.openLocationSettings,
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Future.delayed(const Duration(seconds: 1), () {
                controller.checkPermissionsAndGetLocation();
              });
            },
          );
        }

        // Location permission denied
        if (controller.gpsStatus.value == LocationStatus.permissionDenied ||
            controller.gpsStatus.value == LocationStatus.permissionPermanentlyDenied) {
          return FullScreenErrorMessage(
            message: AppStrings.permissionRequiredMessage,
            buttonText: AppStrings.openAppSettings,
            onPressed: () async {
              await Geolocator.openAppSettings();
              Future.delayed(const Duration(seconds: 1), () {
                controller.checkPermissionsAndGetLocation();
              });
            },
          );
        }

        // Error fallback
        if (controller.errorMessage.value != null &&
            controller.currentPosition.value == null) {
          return FullScreenErrorMessage(
            message: controller.errorMessage.value!,
            buttonText: AppStrings.retry,
            onPressed: controller.checkPermissionsAndGetLocation,
          );
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentPosition.value ?? const LatLng(23.8103, 90.4125), // Dhaka
                zoom: 14,
              ),
              onMapCreated: controller.onMapCreated,
              onTap: controller.onMapTap,
              markers: controller.markers.value,
              polylines: controller.polylines.value,
              myLocationButtonEnabled: false, // We use a custom FAB
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            ),
            if (controller.isLoading.value && controller.currentPosition.value != null)
              const Center(child: CircularProgressIndicator()),

            // UI Overlays
            _buildTopInstructionCard(),
            _buildRouteInfoCard(),
            _buildActionButtons(),
          ],
        );
      }),
    );
  }

  Widget _buildTopInstructionCard() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Obx(() {
        String text;
        if (controller.markers.isEmpty) {
          text = AppStrings.selectOrigin;
        } else if (controller.markers.length == 1) {
          text = AppStrings.selectDestination;
        } else {
          return const SizedBox.shrink();
        }
        return InfoCard(text: text);
      }),
    );
  }

  Widget _buildRouteInfoCard() {
    return Obx(() {
      if (controller.distance.value == null || controller.duration.value == null) {
        return const SizedBox.shrink();
      }
      return Positioned(
        bottom: 30,
        left: 16,
        right: 16,
        child: InfoCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoItem(Icons.social_distance, controller.distance.value!),
              _infoItem(Icons.timer_outlined, controller.duration.value!),
            ],
          ),
        ),
      );
    });
  }

  Widget _infoItem(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: Colors.blueAccent),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'recenter_btn',
            mini: true,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.black54),
            onPressed: () {
              if (controller.currentPosition.value != null) {
                controller.animateToPosition(controller.currentPosition.value!);
              }
            },
          ),
          const SizedBox(height: 10),
          Obx(() => controller.markers.isNotEmpty
              ? FloatingActionButton(
            heroTag: 'clear_btn',
            mini: true,
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.clear, color: Colors.white),
            onPressed: controller.clearRoute,
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

}
