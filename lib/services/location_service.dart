import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}

class LocationService {

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Check current location permission status
  static Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Get current location with address
  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Check and request permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Get address from coordinates
      final address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  /// Get address from coordinates - simplified approach for now
  static Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // For now, return coordinates-based location string
      // This will work globally, not just in Bohol
      
      // Simple region detection based on coordinates
      String region = _getRegionFromCoordinates(latitude, longitude);
      
      return 'Location in $region (${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)})';
    } catch (e) {
      // Fallback to coordinates if any error occurs
      return 'Location: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Simple region detection based on coordinates
  static String _getRegionFromCoordinates(double latitude, double longitude) {
    // Philippines (approximate bounds)
    if (latitude >= 4.0 && latitude <= 21.0 && longitude >= 116.0 && longitude <= 127.0) {
      // Bohol area (more specific)
      if (latitude >= 9.4 && latitude <= 10.2 && longitude >= 123.5 && longitude <= 124.6) {
        return 'Bohol, Philippines';
      }
      // Other parts of Philippines
      return 'Philippines';
    }
    
    // Other countries/regions (you can expand this)
    if (latitude >= 8.0 && latitude <= 38.0 && longitude >= 92.0 && longitude <= 141.0) {
      return 'Southeast Asia';
    }
    
    // Default fallback
    return 'Unknown Region';
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    try {
      final permission = await checkPermission();
      return permission == LocationPermission.always ||
             permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Open device settings for location permissions
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  /// Open device settings for app permissions
  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Get distance between two coordinates in meters
  static double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Generate Google Maps URL for coordinates
  static String getGoogleMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }

  /// Generate Apple Maps URL for coordinates
  static String getAppleMapsUrl(double latitude, double longitude) {
    return 'http://maps.apple.com/?q=$latitude,$longitude';
  }
}
