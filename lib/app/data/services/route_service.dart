import 'package:dio/dio.dart';
import 'package:flutter_car_route_app/app/data/models/route_model.dart';
import 'package:flutter_car_route_app/app/shared/constants/constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  final Dio _dio;

  RouteService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));


  Future<DirectionsModel> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    const String baseUrl = 'https://maps.gomaps.pro/maps/api/directions/json';

    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'origin': '$originLat,$originLng',
          'destination': '$destLat,$destLng',
          'key': ApiKey.directionsKey,
        },
      );

      final data = response.data;
      if (data['status'] == 'OK') {
        return DirectionsModel.fromJson(data);
      } else if (data['status'] == 'ZERO_RESULTS') {
        throw Exception('No route could be found between the origin and destination.');
      } else {
        throw Exception(data['error_message'] ?? 'An unknown error occurred.');
      }
    } on DioException catch (e) {
      // Handle network-related errors
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    } catch (e) {
      // Re-throw other exceptions
      throw Exception('An error occurred while fetching the route: ${e.toString()}');
    }
  }

  /// Decode Google encoded polyline into list of LatLng
  List<LatLng> _decodePolyline(String encoded) {
    final points = PolylinePoints().decodePolyline(encoded);
    return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
}