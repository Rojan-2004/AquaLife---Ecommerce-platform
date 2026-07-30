import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<bool> _ensureLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled');
    }
    return true;
  }

  Future<LocationPermission> _checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> _requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<Position> getCurrentPosition() async {
    await _ensureLocationServiceEnabled();
    final permission = await _checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await _requestPermission();
      if (requested == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied forever');
      }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  Future<Map<String, String?>> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return <String, String?>{};
      }
      final place = placemarks.first;
      return {
        'street': place.street,
        'locality': place.locality,
        'postalCode': place.postalCode,
        'country': place.country,
      };
    } on Exception catch (e) {
      throw Exception('Failed to resolve address: $e');
    }
  }

  Future<Map<String, String?>> getCurrentAddress() async {
    final position = await getCurrentPosition();
    final address = await reverseGeocode(position.latitude, position.longitude);
    return {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
      ...address,
    };
  }

  Future<void> openAppLocationSettings() async {
    await Geolocator.openAppSettings();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
