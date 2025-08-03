import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsModel {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final String routeName;

  DirectionsModel({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
    required this.routeName,
  });

  factory DirectionsModel.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final leg = route['legs'][0];

    final distance = leg['distance']['text'];
    final duration = leg['duration']['text'];
    final routeName = route['summary'] ?? 'Best Route';

    final polyline = route['overview_polyline']['points'];
    final polylinePoints = PolylinePoints().decodePolyline(polyline)
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();

    return DirectionsModel(
      polylinePoints: polylinePoints,
      distance: distance,
      duration: duration,
      routeName: routeName,
    );
  }
}


