import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;
  final String? initialLocationName;
  final String title;
  final String confirmLabel;

  const LocationPicker({
    super.key,
    required this.initialLocation,
    this.initialLocationName,
    this.title = 'Select Location',
    this.confirmLabel = 'Use This Location',
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  final TextEditingController _searchController = TextEditingController();

  final MapController _mapController = MapController();

  late LatLng _selectedLocation;

  String? _selectedName;

  List<LocationSearchResult> _searchResults = const [];

  bool _searching = false;
  bool _gettingCurrentLocation = false;
  bool _reverseGeocoding = false;

  @override
  void initState() {
    super.initState();

    _selectedLocation = widget.initialLocation;

    final initialName = widget.initialLocationName?.trim();

    if (initialName != null && initialName.isNotEmpty) {
      _selectedName = initialName;
      _searchController.text = initialName;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    FocusScope.of(context).unfocus();

    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _showMessage('Please enter a location to search.');
      return;
    }

    setState(() {
      _searching = true;
      _searchResults = const [];
    });

    try {
      final results = await LocationService.searchLocations(query);

      if (!mounted) {
        return;
      }

      setState(() {
        _searchResults = results;
      });

      if (results.isEmpty) {
        _showMessage(
          'No matching locations were found. '
          'Try a barangay, street, landmark, or city.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  // ============================================================
  // SELECT SEARCH RESULT
  // ============================================================

  Future<void> _selectSearchResult(
    LocationSearchResult result,
  ) async {
    setState(() {
      _selectedLocation = result.location;
      _selectedName = result.displayName;
      _searchController.text = result.displayName;
      _searchResults = const [];
    });

    _mapController.move(
      result.location,
      17,
    );
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void> _useCurrentLocation() async {
    setState(() {
      _gettingCurrentLocation = true;
    });

    try {
      final location = await LocationService.getCurrentLocation();

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedLocation = location;
      });

      _mapController.move(
        location,
        17,
      );

      setState(() {
        _reverseGeocoding = true;
      });

      final displayName = await LocationService.reverseGeocode(location);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedName = displayName ??
            '${location.latitude.toStringAsFixed(5)}, '
                '${location.longitude.toStringAsFixed(5)}';

        _searchController.text = _selectedName!;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _gettingCurrentLocation = false;
          _reverseGeocoding = false;
        });
      }
    }
  }

  // ============================================================
  // MAP TAP
  // ============================================================

  Future<void> _onMapTap(
    TapPosition tapPosition,
    LatLng location,
  ) async {
    setState(() {
      _selectedLocation = location;
      _selectedName = null;
      _reverseGeocoding = true;
    });

    try {
      final displayName = await LocationService.reverseGeocode(location);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedName = displayName ??
            '${location.latitude.toStringAsFixed(5)}, '
                '${location.longitude.toStringAsFixed(5)}';

        _searchController.text = _selectedName!;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedName = '${location.latitude.toStringAsFixed(5)}, '
            '${location.longitude.toStringAsFixed(5)}';

        _searchController.text = _selectedName!;
      });
    } finally {
      if (mounted) {
        setState(() {
          _reverseGeocoding = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM
  // ============================================================

  void _confirmLocation() {
    final displayName = _selectedName?.trim();

    final finalName = displayName == null || displayName.isEmpty
        ? '${_selectedLocation.latitude.toStringAsFixed(5)}, '
            '${_selectedLocation.longitude.toStringAsFixed(5)}'
        : displayName;

    Navigator.pop(
      context,
      LocationSelection(
        location: _selectedLocation,
        displayName: finalName,
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? alertRed : primaryTeal,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final dialogWidth = screenWidth > 900 ? 760.0 : screenWidth - 32;

    final dialogHeight = screenHeight > 760
        ? 650.0
        : (screenHeight - 40).clamp(520.0, 650.0).toDouble();

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      actionsPadding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: primaryTeal,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            // ======================================================
            // SEARCH
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Search barangay, street, landmark...',
                      hintStyle: const TextStyle(
                        color: grayText,
                        fontSize: 12.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryTeal,
                        size: 21,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAF9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryTeal,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _searching ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _searching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Search'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ======================================================
            // SEARCH INFORMATION
            // ======================================================

            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: grayText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Search manually, then select a result. '
                    'You can also tap the map to place the pin.',
                    style: const TextStyle(
                      color: grayText,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),

            // ======================================================
            // SEARCH RESULTS
            // ======================================================

            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 145),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: borderColor,
                  ),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];

                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: primaryTeal,
                        size: 20,
                      ),
                      title: Text(
                        result.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _selectSearchResult(result),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 10),

            // ======================================================
            // MAP
            // ======================================================

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 15,
                        minZoom: 3,
                        maxZoom: 19,
                        onTap: _onMapTap,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.pawlink.pawlink',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 50,
                              height: 60,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.location_on,
                                color: alertRed,
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Map instruction
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.10,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 17,
                                color: primaryTeal,
                              ),
                              SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Tap the map to place the report pin.',
                                  style: TextStyle(
                                    color: darkText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Current location button
                    Positioned(
                      right: 12,
                      bottom: 52,
                      child: Material(
                        color: Colors.white,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _gettingCurrentLocation
                              ? null
                              : _useCurrentLocation,
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: _gettingCurrentLocation
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: primaryTeal,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    color: primaryTeal,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // Loading reverse geocode
                    if (_reverseGeocoding)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: primaryTeal,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Attribution
                    Positioned(
                      left: 8,
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        color: Colors.white.withValues(alpha: 0.85),
                        child: const Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(
                            fontSize: 8,
                            color: grayText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ======================================================
            // SELECTED LOCATION
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCBE8E3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: primaryTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected location',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedName ??
                              'Tap the map or search for a location.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: grayText,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: darkText,
            side: const BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirmLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
