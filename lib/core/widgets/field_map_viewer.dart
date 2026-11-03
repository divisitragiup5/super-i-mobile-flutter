import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

class MapPinItem {
  final String id;
  final String title;
  final String? subtitle;
  final double latitude;
  final double longitude;
  final Color color;
  final IconData icon;

  const MapPinItem({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.subtitle,
    this.color = AppColors.primary,
    this.icon = Icons.location_on,
  });
}

/// Widget Peta Interaktif Lapangan untuk Rute Inspeksi SUTM, Tower Line Walker, atau Gardu Induk
class FieldMapViewer extends StatefulWidget {
  final List<LatLng> routePoints;
  final List<MapPinItem> pins;
  final ValueChanged<MapPinItem>? onPinSelected;
  final double initialZoom;
  final LatLng? initialCenter;
  final double height;

  const FieldMapViewer({
    super.key,
    this.routePoints = const [],
    this.pins = const [],
    this.onPinSelected,
    this.initialZoom = 14.5,
    this.initialCenter,
    this.height = 320,
  });

  @override
  State<FieldMapViewer> createState() => _FieldMapViewerState();
}

class _FieldMapViewerState extends State<FieldMapViewer> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (mounted) setState(() => _currentPosition = pos);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (mounted) setState(() => _currentPosition = last);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _centerToMyLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      );
    } else {
      _fetchCurrentLocation();
    }
  }

  void _fitAllMarkers() {
    final allPoints = <LatLng>[
      ...widget.routePoints,
      ...widget.pins.map((p) => LatLng(p.latitude, p.longitude)),
    ];
    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(allPoints);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng center = widget.initialCenter ??
        (widget.pins.isNotEmpty
            ? LatLng(widget.pins.first.latitude, widget.pins.first.longitude)
            : (widget.routePoints.isNotEmpty
                ? widget.routePoints.first
                : const LatLng(-6.200000, 106.816666)));

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: widget.initialZoom,
              ),
              children: [
                // 1. OSM Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bagaskoro.super_i_mobile',
                ),

                // 2. Polyline Rute Jalur
                if (widget.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.routePoints,
                        strokeWidth: 4.0,
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                // 3. Markers Pin Titik Aset
                MarkerLayer(
                  markers: [
                    // Posisi Petugas Saat Ini
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Pin Aset (Tiang SUTM / Tower / Gardu)
                    ...widget.pins.map((pin) {
                      return Marker(
                        point: LatLng(pin.latitude, pin.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => widget.onPinSelected?.call(pin),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: pin.color,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  pin.icon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // Kontrol Tombol Peta di Kanan Bawah
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'fit_all',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: _fitAllMarkers,
                    child: const Icon(Icons.fullscreen),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'my_loc',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: _centerToMyLocation,
                    child: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
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
