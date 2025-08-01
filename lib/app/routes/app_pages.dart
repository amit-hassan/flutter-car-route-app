
import 'package:flutter_car_route_app/app/modules/home/home_binding.dart';
import 'package:flutter_car_route_app/app/modules/home/home_view.dart';
import 'package:flutter_car_route_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}