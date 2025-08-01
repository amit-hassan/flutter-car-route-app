import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Route')),
      body: Stack(
        children: [
          // Google Map
          Obx(() {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.initialPosition,
                zoom: 14,
              ),
              onMapCreated: controller.onMapCreated,
              markers: controller.markers.toSet(),
              onTap: controller.addMarker,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // We provide custom FAB
              compassEnabled: true,
              zoomControlsEnabled: false,
            );
          }),

          // Offline Banner
          Obx(() {
            if (!controller.isOffline.value) return const SizedBox();
            return Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'No Internet Connection. Waiting to reconnect...',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),

          // Action Buttons
          Positioned(
            right: 16,
            bottom: 40,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'my_location',
                  backgroundColor: Colors.white,
                  onPressed: controller.centerOnUser,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'reset_markers',
                  backgroundColor: Colors.white,
                  onPressed: controller.resetMarkers,
                  child: const Icon(Icons.refresh, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
