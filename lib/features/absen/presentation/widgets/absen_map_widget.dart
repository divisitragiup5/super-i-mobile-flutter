import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/absen_location_entity.dart';

class AbsenMapWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Pusat peta: posisi user atau lokasi absen pertama
    final centerLat =
        userPosition?.latitude ??
        (absenLocation?.coordinates.isNotEmpty == true
            ? absenLocation!.coordinates.first.latitude
            : -6.200000);
    final centerLng =
        userPosition?.longitude ??
        (absenLocation?.coordinates.isNotEmpty == true
            ? absenLocation!.coordinates.first.longitude
            : 106.816666);

    final centerPoint = LatLng(centerLat, centerLng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          options: MapOptions(initialCenter: centerPoint, initialZoom: 16.0),
          children: [
            // Layer Peta OpenStreetMap (Gratis & Ringan)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.bagaskoro.super_i_mobile',
            ),

            // Lingkaran Radius Geofence
            if (absenLocation != null)
              CircleLayer(
                circles: absenLocation!.coordinates.map((coord) {
                  return CircleMarker(
                    point: LatLng(coord.latitude, coord.longitude),
                    radius: absenLocation!.radius,
                    useRadiusInMeter: true,
                    color: isInsideRadius
                        ? const Color(0xFF4ADE80).withValues(alpha: 0.35)
                        : const Color(0xFFEF4444).withValues(alpha: 0.35),
                    borderColor: isInsideRadius
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),

            // Marker Lokasi
            MarkerLayer(
              markers: [
                // Marker User
                if (userPosition != null)
                  Marker(
                    point: LatLng(
                      userPosition!.latitude,
                      userPosition!.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blueAccent,
                      size: 38,
                    ),
                  ),

                // Marker Lokasi Gardu Induk
                if (absenLocation != null)
                  ...absenLocation!.coordinates.map(
                    (coord) => Marker(
                      point: LatLng(coord.latitude, coord.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
