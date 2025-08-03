import 'package:flutter_test/flutter_test.dart';

class MockLocationService {
  Future<String> getCurrentPosition() async => 'Lat:0, Lng:0';
}

void main() {
  test('getCurrentPosition returns mock value', () async {
    final mockService = MockLocationService();
    final position = await mockService.getCurrentPosition();
    expect(position, 'Lat:0, Lng:0');
  });
}
