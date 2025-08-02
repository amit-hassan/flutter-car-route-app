import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => !_isConnectionNone(results));

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !_isConnectionNone(result);
  }

  bool _isConnectionNone(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.none);
  }
}