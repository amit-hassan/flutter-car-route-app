import 'package:dio/dio.dart';
import 'package:flutter_car_route_app/app/data/models/route_model.dart';
import 'package:flutter_car_route_app/app/shared/constants/constants.dart';

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
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    } catch (e) {
      throw Exception('An error occurred while fetching the route: ${e.toString()}');
    }
  }

}