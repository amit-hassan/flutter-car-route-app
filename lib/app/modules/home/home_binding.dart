
import 'package:flutter_car_route_app/app/data/helpers/helpers.dart';
import 'package:flutter_car_route_app/app/data/services/services.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MapService());
    Get.lazyPut(() => LocationService());
    Get.lazyPut(() => RouteService());
    Get.lazyPut(() => ConnectivityHelper());
    Get.lazyPut(() => PermissionHelper());

    Get.lazyPut(() => HomeController(
      mapService: Get.find(),
      locationService: Get.find(),
      routeService: Get.find(),
      permissionHelper: Get.find(),
      connectivityHelper: Get.find(),
    ));
  }
}
