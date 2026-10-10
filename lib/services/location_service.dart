import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  final LatLng location;
  final String displayName;

  const LocationSearchResult({
    required this.location,
    required this.displayName,
  });
}

class LocationSelection {
  final LatLng location;
  final String displayName;

  const LocationSelection({
    required this.location,
    required this.displayName,
  });
}

class LocationService {
  LocationService._();

  static const String _nominatimHost = 'nominatim.openstreetmap.org';

  // The public Nominatim service requires an identifiable User-Agent.
  static const String _userAgent = 'PawLink/1.0';

  static Future<List<LocationSearchResult>> searchLocations(
    String query,
  ) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return const [];
    }

    final uri = Uri.https(
      _nominatimHost,
      '/search',
      <String, String>{
        'q': trimmedQuery,
        'format': 'jsonv2',
        'limit': '5',
        'addressdetails': '1',
        'countrycodes': 'ph',
      },
    );

    final response = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
        'User-Agent': _userAgent,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Location search is temporarily unavailable. Please try again.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return const [];
    }

    final results = <LocationSearchResult>[];

    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }

      final latitude = double.tryParse(item['lat']?.toString() ?? '');
      final longitude = double.tryParse(item['lon']?.toString() ?? '');
      final displayName = item['display_name']?.toString().trim() ?? '';

      if (latitude == null || longitude == null || displayName.isEmpty) {
        continue;
      }

      results.add(
        LocationSearchResult(
          location: LatLng(latitude, longitude),
          displayName: displayName,
        ),
      );
    }

    return results;
  }

  static Future<String?> reverseGeocode(LatLng location) async {
    final uri = Uri.https(
      _nominatimHost,
      '/reverse',
      <String, String>{
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
        'format': 'jsonv2',
        'addressdetails': '1',
        'zoom': '18',
      },
    );

    final response = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
        'User-Agent': _userAgent,
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      return null;
    }

    final displayName = decoded['display_name']?.toString().trim();

    if (displayName == null || displayName.isEmpty) {
      return null;
    }

    return displayName;
  }

  static Future<LatLng> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location services are turned off. You can still search or pin the map manually.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission was denied. You can still search or pin the map manually.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is blocked. You can still search or pin the map manually.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  static Future<LocationSelection> selectionFromCoordinates(
    LatLng location, {
    String? fallbackName,
  }) async {
    final name = await reverseGeocode(location);

    return LocationSelection(
      location: location,
      displayName: name ??
          (fallbackName?.trim().isNotEmpty == true
              ? fallbackName!.trim()
              : '${location.latitude.toStringAsFixed(5)}, '
                  '${location.longitude.toStringAsFixed(5)}'),
    );
  }
}
