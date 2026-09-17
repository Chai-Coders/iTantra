import 'dart:math';

class GeoCoordinates {
  final double latitude;
  final double longitude;
  final double altitude;

  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
  });

  @override
  String toString() => '${latitude.toStringAsFixed(4)}°N, ${longitude.toStringAsFixed(4)}°E';
}

class GeoEngine {
  static final GeoEngine _instance = GeoEngine._internal();
  factory GeoEngine() => _instance;
  GeoEngine._internal();

  // Local anchor node reference coordinates (Disaster Sector Baseline)
  GeoCoordinates _currentLocation = const GeoCoordinates(
    latitude: 9.7460,
    longitude: 76.6548,
    altitude: 180.0,
  );

  GeoCoordinates get currentLocation => _currentLocation;

  void updateLocation(double lat, double lon, [double alt = 0.0]) {
    _currentLocation = GeoCoordinates(latitude: lat, longitude: lon, altitude: alt);
  }

  /// Calculates geodesic distance between two points in meters using the Haversine formula
  double calculateDistance(GeoCoordinates from, GeoCoordinates to) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(from.latitude)) *
            cos(_toRadians(to.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculates initial azimuth compass bearing from reference point to target point (0° to 360°)
  double calculateBearing(GeoCoordinates from, GeoCoordinates to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final radians = atan2(y, x);
    final degrees = (radians * 180 / pi + 360) % 360;

    return degrees;
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  double _toRadians(double degrees) => degrees * pi / 180.0;
}