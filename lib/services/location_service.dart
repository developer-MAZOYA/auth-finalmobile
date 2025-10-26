import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  static Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  }) async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: desiredAccuracy,
    );
  }

  // Get address from coordinates
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];

        // Build address string
        String address = '';
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          address += '${placemark.street}, ';
        }
        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty) {
          address += '${placemark.subLocality}, ';
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          address += '${placemark.locality}, ';
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          address += '${placemark.administrativeArea}, ';
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          address += placemark.country!;
        }

        return address.isNotEmpty ? address.trim() : 'Address not available';
      }
      return 'Address not found';
    } catch (e) {
      return 'Unable to get address: $e';
    }
  }

  // Get complete location data with timestamp
  static Future<Map<String, dynamic>> getCompleteLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
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
      Position position = await getCurrentPosition();

      // Get address
      String address =
          await getAddressFromLatLng(position.latitude, position.longitude);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
        'heading': position.heading,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'formattedTime': DateTime.now().toIso8601String(),
        'address': address,
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get distance between two coordinates in meters
  static double calculateDistance(
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

  // Check if we have location permission
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app settings for permission management
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Get last known position (cached)
  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }
}
