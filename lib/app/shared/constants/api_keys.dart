class ApiKey {
  static const String directionsKey = String.fromEnvironment(
    'DIRECTIONS_API_KEY',
    defaultValue: 'No Directions key found',
  );
}