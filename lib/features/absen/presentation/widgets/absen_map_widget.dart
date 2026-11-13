import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/map_marker_bitmap_helper.dart';
import '../../domain/entities/absen_location_entity.dart';

class AbsenMapWidget extends StatefulWidget {
  final Position? userPosition;
  final AbsenLocationEntity? absenLocation;
  final bool isInsideRadius;

  const AbsenMapWidget({
    super.key,
    this.userPosition,
    this.absenLocation,
    required this.isInsideRadius,
  });

  @override
  State<AbsenMapWidget> createState() => _AbsenMapWidgetState();
}

class _AbsenMapWidgetState extends State<AbsenMapWidget>
    with WidgetsBindingObserver {
  GoogleMapController? _controller;
  final Map<String, BitmapDescriptor> _radiusLabelIcons = {};
  BitmapDescriptor? _userMarkerIcon;
  bool _isDarkMode = false;
  bool _hasInitialFitted = false;
  static const double _minZoomForRadiusLabel = 14.0;
  bool _showRadiusLabel = true;

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
    _loadCustomMarkers();
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
      _loadCustomMarkers();
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
      _loadCustomMarkers();
    }
  }

  @override
  void didUpdateWidget(covariant AbsenMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userPosition != null &&
        (oldWidget.userPosition?.latitude != widget.userPosition?.latitude ||
            oldWidget.userPosition?.longitude !=
                widget.userPosition?.longitude)) {
      if (!_hasInitialFitted) {
        _fitBoundsOrOffice();
      }
    }

    if (oldWidget.absenLocation != widget.absenLocation ||
        oldWidget.isInsideRadius != widget.isInsideRadius) {
      _loadCustomMarkers();
    }
  }

  Future<void> _loadCustomMarkers() async {
    final Map<String, BitmapDescriptor> newIcons = {};

    // 1. Label untuk Radius Shape
    if (widget.absenLocation != null) {
      for (int i = 0; i < widget.absenLocation!.coordinates.length; i++) {
        final coord = widget.absenLocation!.coordinates[i];
        try {
          final icon = await MapMarkerBitmapHelper.getRadiusLabelMarker(
            label: coord.nama,
            radius: widget.absenLocation!.radius,
            isInside: widget.isInsideRadius,
            isDark: _isDarkMode,
          );
          newIcons['radius_$i'] = icon;
        } catch (_) {}
      }
    }

    // 2. Marker Khusus User ("Lokasi Saat Ini")
    BitmapDescriptor? userIcon;
    try {
      userIcon = await MapMarkerBitmapHelper.getCustomMarker(
        label: 'Lokasi Saat Ini',
        color: const Color(0xFFEF4444),
        isUser: true,
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _radiusLabelIcons.clear();
        _radiusLabelIcons.addAll(newIcons);
        if (userIcon != null) {
          _userMarkerIcon = userIcon;
        }
      });
    }
  }

  void _fitBoundsOrOffice() {
    if (_controller == null) return;

    final allCoords = <LatLng>[];
    if (widget.userPosition != null) {
      allCoords.add(
        LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude),
      );
    }
    if (widget.absenLocation != null) {
      for (final coord in widget.absenLocation!.coordinates) {
        allCoords.add(LatLng(coord.latitude, coord.longitude));
      }
    }

    if (allCoords.isEmpty) return;

    if (allCoords.length == 1) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(allCoords.first, 16.0),
      );
      _hasInitialFitted = true;
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

    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        55.0,
      ),
    );
    _hasInitialFitted = true;
  }

  void _focusToUser() {
    if (_controller == null || widget.userPosition == null) return;
    _controller!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude),
        16.5,
      ),
    );
  }

  Future<void> _updateZoom(double delta) async {
    if (_controller == null) return;
    final zoom = await _controller!.getZoomLevel();
    _controller!.animateCamera(CameraUpdate.zoomTo(zoom + delta));
  }

  void _updateRadiusLabelVisibility(double zoom) {
    final shouldShow = zoom >= _minZoomForRadiusLabel;
    if (shouldShow != _showRadiusLabel) {
      if (mounted) {
        setState(() {
          _showRadiusLabel = shouldShow;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = deviceBrightness == Brightness.dark;

    final centerLat =
        widget.absenLocation?.coordinates.isNotEmpty == true
            ? widget.absenLocation!.coordinates.first.latitude
            : (widget.userPosition?.latitude ?? -6.200000);
    final centerLng =
        widget.absenLocation?.coordinates.isNotEmpty == true
            ? widget.absenLocation!.coordinates.first.longitude
            : (widget.userPosition?.longitude ?? 106.816666);

    final centerPoint = LatLng(centerLat, centerLng);

    final Set<Circle> circles = {};
    final Set<Marker> markers = {};

    double radiusValue = 100.0;

    if (widget.absenLocation != null) {
      radiusValue = widget.absenLocation!.radius;
      for (int i = 0; i < widget.absenLocation!.coordinates.length; i++) {
        final coord = widget.absenLocation!.coordinates[i];
        final latLng = LatLng(coord.latitude, coord.longitude);

        // 1. Shape Geofence Circle
        circles.add(
          Circle(
            circleId: CircleId('geofence_$i'),
            center: latLng,
            radius: widget.absenLocation!.radius,
            fillColor: widget.isInsideRadius
                ? const Color(0xFF4ADE80).withValues(alpha: isDark ? 0.25 : 0.35)
                : const Color(0xFFEF4444).withValues(alpha: isDark ? 0.25 : 0.35),
            strokeColor: widget.isInsideRadius
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
            strokeWidth: 2,
          ),
        );

        // 2. Langsung tampilkan label di shape radius (center: latLng)
        // Hanya dimunculkan ketika map zoom di rentang ~2-3 km atau lebih dekat (zoom >= 14.0)
        if (_showRadiusLabel) {
          final labelIcon = _radiusLabelIcons['radius_$i'];
          if (labelIcon != null) {
            markers.add(
              Marker(
                markerId: MarkerId('radius_label_$i'),
                position: latLng,
                infoWindow: InfoWindow(
                  title: coord.nama.isNotEmpty ? coord.nama : 'Titik Presensi',
                  snippet: 'Radius ${radiusValue.toInt()}m',
                ),
                icon: labelIcon,
                anchor: const Offset(0.5, 0.5),
                zIndexInt: 10,
              ),
            );
          }
        }
      }
    }

    // 3. Hanya marker untuk lokasi user saja ("Lokasi Saat Ini")
    if (widget.userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_position'),
          position: LatLng(
            widget.userPosition!.latitude,
            widget.userPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
          icon:
              _userMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.95),
          zIndexInt: 999,
        ),
      );
    }

    // Styling tombol toolbox di kiri atas (sesuai foto)
    final toolboxBg =
        isDark ? const Color(0xFF1E293B) : Colors.white;
    final toolboxBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final toolboxIconColor =
        isDark ? Colors.white : const Color(0xFF334155);
    final toolboxDivider =
        isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 280,
        color: isDark ? const Color(0xFF242F3E) : const Color(0xFFE5E7EB),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: centerPoint,
                zoom: 15.5,
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
                _controller = controller;
                _fitBoundsOrOffice();
                final zoom = await controller.getZoomLevel();
                _updateRadiusLabelVisibility(zoom);
              },
              onCameraMove: (position) {
                _updateRadiusLabelVisibility(position.zoom);
              },
              onCameraIdle: () async {
                if (_controller != null) {
                  final zoom = await _controller!.getZoomLevel();
                  _updateRadiusLabelVisibility(zoom);
                }
              },
              circles: circles,
              markers: markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: true, // Mengaktifkan rute & tombol Google Maps bawaan saat marker ditekan
            ),

            // Floating Action Toolbox (Kiri Atas sesuai foto)
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
                        onPressed: _focusToUser,
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
        ),
      ),
    );
  }
}


