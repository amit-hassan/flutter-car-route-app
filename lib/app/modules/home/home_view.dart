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
        if (controller.isLoading.value &&
            controller.currentPosition.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
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

        if (controller.gpsStatus.value == LocationStatus.permissionDenied ||
            controller.gpsStatus.value ==
                LocationStatus.permissionPermanentlyDenied) {
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
                target: controller.currentPosition.value ??
                    const LatLng(23.8103, 90.4125),
                zoom: 14,
              ),
              onMapCreated: controller.onMapCreated,
              onTap: controller.onMapTap,
              markers: controller.markers.value,
              polylines: controller.polylines.value,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            ),
            if (controller.isLoading.value &&
                controller.currentPosition.value != null)
              const Center(child: CircularProgressIndicator()),
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
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top blue address card
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 20, left: 12, right: 12),
            color: Colors.blue[700],
            child: Row(
              children: [
                const Icon(Icons.directions_car_filled_outlined, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => _buildAddressRow("from: ", controller.originName.value ?? '...')),
                      const Divider(color: Colors.white54, thickness: 0.5, height: 16),
                      Obx(() => _buildAddressRow("to: ", controller.destinationName.value ?? '...')),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: controller.clearRoute,
                ),
              ],
            ),
          ),

          // Centered instruction message below blue card
          Obx(() {
            String text;
            if (controller.markers.isEmpty) {
              text = AppStrings.selectOrigin;
            } else if (controller.markers.length == 1) {
              text = AppStrings.selectDestination;
            } else {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: InfoCard(text: text),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Good practice to prevent wrapping
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfoCard() {
    return Obx(() {
      if (controller.distance.value == null ||
          controller.duration.value == null) {
        return const SizedBox.shrink();
      }

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "${controller.duration.value!} ",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "(${controller.distance.value!})",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "via A41",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    });
  }

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
