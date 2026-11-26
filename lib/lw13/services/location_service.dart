import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Why we could not get a position.
enum LocationIssue {
  /// GPS / location switch of the device is OFF.
  serviceDisabled,

  /// User tapped "Deny" (we may ask again).
  denied,

  /// "Don't ask again" on Android / denied on iOS: only Settings can fix it.
  deniedForever,

  /// Timeout or any other platform problem.
  unavailable,
}

class LocationException implements Exception {
  final LocationIssue issue;
  final String message;
  const LocationException(this.issue, this.message);

  @override
  String toString() => message;
}

/// All geolocator logic in one place. The screen only calls [currentPosition]
/// and reacts to [LocationException] - it never touches the plugin directly.
class LocationService {
  Future<Position> currentPosition() async {
    // 1) Is the GPS switch on?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        LocationIssue.serviceDisabled,
        'Location services are turned off.',
      );
    }

    // 2) Do we have permission? Ask at runtime if not.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        LocationIssue.denied,
        'Location permission was denied.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        LocationIssue.deniedForever,
        'Location permission is permanently denied.',
      );
    }

    // 3) Wait for the GPS fix (high accuracy == desiredAccuracy: high).
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw const LocationException(
        LocationIssue.unavailable,
        'Could not get a GPS fix in time. Try again outdoors.',
      );
    } catch (e) {
      throw LocationException(
        LocationIssue.unavailable,
        'Could not read the location: $e',
      );
    }
  }
}
