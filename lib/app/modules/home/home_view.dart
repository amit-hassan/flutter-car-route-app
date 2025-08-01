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
          Obx(() {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.initialPosition,
                zoom: 14,
              ),
              onMapCreated: controller.onMapCreated,
              markers: controller.markers.value,
              onTap: controller.addMarker,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            );
          }),
          // Offline Banner
          Obx(() {
            if (!controller.isOffline.value) return const SizedBox();
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'No Internet Connection. Waiting to reconnect...',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.resetMarkers,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
