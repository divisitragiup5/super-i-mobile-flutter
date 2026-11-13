import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/map_marker_bitmap_helper.dart';

class SutmMapItem {
  final String? idAsset;
  final String? name;
  final dynamic latitude;
  final dynamic longitude;
  final Color? color;
  final dynamic rawData;

  const SutmMapItem({
    this.idAsset,
    this.name,
    this.latitude,
    this.longitude,
    this.color,
    this.rawData,
  });

  double? get lat {
    if (latitude == null) return null;
    if (latitude is num) return (latitude as num).toDouble();
    return double.tryParse(latitude.toString());
  }

  double? get lng {
    if (longitude == null) return null;
    if (longitude is num) return (longitude as num).toDouble();
    return double.tryParse(longitude.toString());
  }
}

class GoogleSutmMapCard extends StatefulWidget {
  final List<SutmMapItem> items;
  final double? height;
  final double? initialRadius;
  final IconData icon;
  final ValueChanged<SutmMapItem>? onMarkerPress;
  final List<LatLng>? routePoints;

  const GoogleSutmMapCard({
    super.key,
    required this.items,
    this.height = 250,
    this.initialRadius,
    this.icon = Icons.flash_on,
    this.onMarkerPress,
    this.routePoints,
  });

  @override
  State<GoogleSutmMapCard> createState() => _GoogleSutmMapCardState();
}

class _GoogleSutmMapCardState extends State<GoogleSutmMapCard>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  Position? _currentLocation;
  bool _isLoadingLocation = true;
  final Map<String, Marker> _markers = {};
  bool _hasInitialFitted = false;
  bool _isDarkMode = false;
  static const double _minZoomForLabel = 14.0;
  bool _showLabel = true;

  static const String _darkMapStyle = '''[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#263c3f"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6b9a76"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#212a37"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9ca5b3"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#746855"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1f2835"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#f3d19c"}]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{"color": "#2f3948"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#515c6d"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#17263c"}]
  }
]''';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isDarkMode =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    _fetchLiveLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    if (isDark != _isDarkMode) {
      if (mounted) {
        setState(() {
          _isDarkMode = isDark;
        });
      }
      _buildMarkers();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark =
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    if (isDark != _isDarkMode) {
      if (mounted) {
        setState(() {
          _isDarkMode = isDark;
        });
      }
      _buildMarkers();
    }
  }

  @override
  void didUpdateWidget(covariant GoogleSutmMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _hasInitialFitted = false;
      _buildMarkers();
    }
  }

  Future<void> _fetchLiveLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (mounted) {
        setState(() {
          _currentLocation = pos;
          _isLoadingLocation = false;
        });
        _buildMarkers();
        _fitBoundsOrUser();
      }
    } catch (_) {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (mounted) {
        setState(() {
          _currentLocation = lastPos;
          _isLoadingLocation = false;
        });
        _buildMarkers();
        _fitBoundsOrUser();
      }
    }
  }

  Future<void> _buildMarkers() async {
    final Map<String, Marker> newMarkers = {};

    // 1. User Location Marker
    if (_currentLocation != null) {
      final userIcon = await MapMarkerBitmapHelper.getCustomMarker(
        label: 'Lokasi Saat Ini',
        color: const Color(0xFFEF4444),
        isUser: true,
        showLabel: _showLabel,
      );

      newMarkers['user_loc'] = Marker(
        markerId: const MarkerId('user_loc'),
        position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        icon: userIcon,
        infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
        zIndexInt: 999,
        anchor: const Offset(0.5, 0.95),
      );
    }

    // 2. SUTM Tiang Markers
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final lat = item.lat;
      final lng = item.lng;
      if (lat == null || lng == null || (lat == 0 && lng == 0)) continue;

      final label = (item.idAsset != null && item.idAsset!.isNotEmpty)
          ? item.idAsset!
          : (item.name != null && item.name!.isNotEmpty ? item.name! : 'Tiang');
      final color = item.color ?? const Color(0xFFEF4444);

      final icon = await MapMarkerBitmapHelper.getCustomMarker(
        label: label,
        color: color,
        isUser: false,
        showLabel: _showLabel,
      );

      final markerIdStr = 'sutm_${item.idAsset ?? i}';
      newMarkers[markerIdStr] = Marker(
        markerId: MarkerId(markerIdStr),
        position: LatLng(lat, lng),
        icon: icon,
        infoWindow: InfoWindow(
          title: label,
          snippet: item.name ?? '',
        ),
        anchor: const Offset(0.5, 0.95),
        onTap: () {
          widget.onMarkerPress?.call(item);
        },
      );
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }
  }

  void _updateLabelVisibility(double zoom) {
    final shouldShow = zoom >= _minZoomForLabel;
    if (shouldShow != _showLabel) {
      _showLabel = shouldShow;
      _buildMarkers();
    }
  }

  void _fitBoundsOrUser() {
    if (_mapController == null || _hasInitialFitted) return;

    if (widget.initialRadius != null && _currentLocation != null) {
      _focusToUser();
      _hasInitialFitted = true;
    } else {
      _fitBounds();
      _hasInitialFitted = true;
    }
  }

  void _focusToUser() {
    if (_mapController == null || _currentLocation == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          zoom: 16.5,
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null) return;

    final allCoords = <LatLng>[];
    for (final item in widget.items) {
      final lat = item.lat;
      final lng = item.lng;
      if (lat != null && lng != null && (lat != 0 || lng != 0)) {
        allCoords.add(LatLng(lat, lng));
      }
    }
    if (_currentLocation != null) {
      allCoords.add(LatLng(_currentLocation!.latitude, _currentLocation!.longitude));
    }
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      allCoords.addAll(widget.routePoints!);
    }

    if (allCoords.isEmpty) return;

    if (allCoords.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: allCoords.first, zoom: 16.0),
        ),
      );
      return;
    }

    double minLat = allCoords.first.latitude;
    double maxLat = allCoords.first.latitude;
    double minLng = allCoords.first.longitude;
    double maxLng = allCoords.first.longitude;

    for (final c in allCoords) {
      minLat = math.min(minLat, c.latitude);
      maxLat = math.max(maxLat, c.latitude);
      minLng = math.min(minLng, c.longitude);
      maxLng = math.max(maxLng, c.longitude);
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        48.0,
      ),
    );
  }

  Future<void> _updateZoom(double delta) async {
    if (_mapController == null) return;
    final zoom = await _mapController!.getZoomLevel();
    _mapController!.animateCamera(CameraUpdate.zoomTo(zoom + delta));
  }

  @override
  Widget build(BuildContext context) {
    final deviceBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = deviceBrightness == Brightness.dark;

    final defaultTarget = _currentLocation != null
        ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
        : (widget.items.isNotEmpty &&
                widget.items.first.lat != null &&
                widget.items.first.lng != null
            ? LatLng(widget.items.first.lat!, widget.items.first.lng!)
            : const LatLng(-6.2088, 106.8456));

    final Set<Polyline> polylines = {};
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('sutm_route'),
          points: widget.routePoints!,
          color: const Color(0xFF016E7F),
          width: 4,
        ),
      );
    }

    // Styling tombol toolbox di kiri atas (sesuai super-i-mobile / absen map)
    final toolboxBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final toolboxBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final toolboxIconColor =
        isDark ? Colors.white : const Color(0xFF334155);
    final toolboxDivider =
        isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    Widget content = Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: defaultTarget,
            zoom: 15.0,
          ),
          style: isDark ? _darkMapStyle : null,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          onMapCreated: (controller) async {
            _mapController = controller;
            _fitBoundsOrUser();
            final zoom = await controller.getZoomLevel();
            _updateLabelVisibility(zoom);
          },
          onCameraMove: (position) {
            _updateLabelVisibility(position.zoom);
          },
          onCameraIdle: () async {
            if (_mapController != null) {
              final zoom = await _mapController!.getZoomLevel();
              _updateLabelVisibility(zoom);
            }
          },
          markers: _markers.values.toSet(),
          polylines: polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: true, // Mengaktifkan rute & tombol Google Maps bawaan saat marker ditekan
        ),

        if (_isLoadingLocation && _markers.isEmpty)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF016E7F)),
            ),
          ),

        // Floating Action Toolbox (Kiri Atas sesuai super-i-mobile / foto)
        Positioned(
          top: 14,
          left: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tombol Fokus Lokasi User
              Container(
                decoration: BoxDecoration(
                  color: toolboxBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: toolboxBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Tooltip(
                  message: 'Lokasi Anda',
                  child: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: toolboxIconColor,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: _currentLocation != null ? _focusToUser : _fitBounds,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 2. Tombol Zoom In / Zoom Out
              Container(
                decoration: BoxDecoration(
                  color: toolboxBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: toolboxBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Perbesar',
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: toolboxIconColor,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _updateZoom(1.0),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 32,
                      color: toolboxDivider,
                    ),
                    Tooltip(
                      message: 'Perkecil',
                      child: IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: toolboxIconColor,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _updateZoom(-1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.height != null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF242F3E) : const Color(0xFFE5E7EB),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}
