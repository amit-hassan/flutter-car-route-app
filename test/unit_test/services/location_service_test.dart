import 'package:flutter_test/flutter_test.dart';

// Simple mock class for demonstration
class MockLocationService {
  Future<String> getCurrentPosition() async => 'Lat:0, Lng:0';
  Future<bool> requestPermission() async => true;
}

void main() {
  late MockLocationService mockService;

  setUp(() {
    mockService = MockLocationService();
  });

  test('getCurrentPosition returns mock value', () async {
    final position = await mockService.getCurrentPosition();
    expect(position, 'Lat:0, Lng:0');
  });

  test('requestPermission returns true', () async {
    final granted = await mockService.requestPermission();
    expect(granted, isTrue);
  });

  test('sequential calls return consistent results', () async {
    final pos1 = await mockService.getCurrentPosition();
    final pos2 = await mockService.getCurrentPosition();
    expect(pos1, pos2);
  });
}
