import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import 'google_sutm_map_card.dart';

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

/// Widget Peta Interaktif Lapangan menggunakan Google Maps
class FieldMapViewer extends StatelessWidget {
  final List<dynamic> routePoints;
  final List<MapPinItem> pins;
  final ValueChanged<MapPinItem>? onPinSelected;
  final double initialZoom;
  final dynamic initialCenter;
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
  Widget build(BuildContext context) {
    final sutmItems = pins.map((p) {
      return SutmMapItem(
        idAsset: p.title,
        name: p.subtitle ?? p.title,
        latitude: p.latitude,
        longitude: p.longitude,
        color: p.color,
        rawData: p,
      );
    }).toList();

    List<LatLng>? parsedRoute;
    if (routePoints.isNotEmpty) {
      parsedRoute = [];
      for (final pt in routePoints) {
        if (pt is LatLng) {
          parsedRoute.add(pt);
        } else if (pt != null) {
          try {
            parsedRoute.add(LatLng(pt.latitude as double, pt.longitude as double));
          } catch (_) {}
        }
      }
    }

    return GoogleSutmMapCard(
      items: sutmItems,
      height: height,
      routePoints: parsedRoute,
      onMarkerPress: (item) {
        if (item.rawData is MapPinItem && onPinSelected != null) {
          onPinSelected!(item.rawData as MapPinItem);
        }
      },
    );
  }
}
