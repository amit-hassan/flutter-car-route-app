import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Route App')),
      body: Obx(() {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: controller.initialPosition,
            zoom: 14,
          ),
          onMapCreated: controller.onMapCreated,
          markers: controller.markers.value,
          onTap: (position) {
            controller.addMarker(position);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.resetMarkers,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}