import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/widgets/google_sutm_map_card.dart';
import '../../data/models/yantek_asset_model.dart';
import '../cubit/yantek_cubit.dart';
import '../widgets/last_inspeksi_modal.dart';

class InspeksiYantekPage extends StatefulWidget {
  const InspeksiYantekPage({super.key});

  @override
  State<InspeksiYantekPage> createState() => _InspeksiYantekPageState();
}

class _InspeksiYantekPageState extends State<InspeksiYantekPage> {
  Position? _lastFetchPos;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initLiveLocation();
  }

  double _getDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371e3;
    double toRad(double deg) => (deg * math.pi) / 180;
    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  Future<void> _initLiveLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (mounted) {
        _handleNewPosition(pos);
      }
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        _handleNewPosition(last);
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _handleNewPosition(Position pos) {
    if (_lastFetchPos == null ||
        _getDistanceInMeters(
              _lastFetchPos!.latitude,
              _lastFetchPos!.longitude,
              pos.latitude,
              pos.longitude,
            ) >=
            500) {
      _lastFetchPos = pos;
      _fetchNearbyAssets(pos);
    }
  }

  void _fetchNearbyAssets(Position pos) {
    final lat = pos.latitude;
    final lng = pos.longitude;

    const deltaLat = 1 / 111.32;
    final deltaLng = 1 / (111.32 * math.cos((lat * math.pi) / 180));

    final params = YantekFilterParams(
      lat: lat,
      lng: lng,
      minLat: lat - deltaLat,
      maxLat: lat + deltaLat,
      minLng: lng - deltaLng,
      maxLng: lng + deltaLng,
    );

    context.read<YantekCubit>().fetchMapAssets(params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Aset SUTM Yantek'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Perbarui Lokasi',
            onPressed: _initLiveLocation,
          ),
        ],
      ),
      body: BlocBuilder<YantekCubit, YantekState>(
        builder: (context, state) {
          if (state is YantekLoading && _lastFetchPos == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final assets = state is YantekLoaded ? state.assets : <YantekAssetModel>[];

          final mapItems = assets.map((a) {
            final color = ColorParser.parse(
              a.lastInspeksi?.healthIndex?.color,
              fallback: const Color(0xFFEF4444),
            );

            return SutmMapItem(
              idAsset: a.idAsset,
              name: a.nama,
              latitude: a.latitude,
              longitude: a.longitude,
              color: color,
              rawData: a,
            );
          }).toList();

          return Stack(
            children: [
              GoogleSutmMapCard(
                items: mapItems,
                height: null,
                initialRadius: 100,
                onMarkerPress: (item) {
                  if (item.rawData is YantekAssetModel) {
                    LastInspeksiModal.show(
                      context,
                      item.rawData as YantekAssetModel,
                    );
                  }
                },
              ),

              // Top Status Pill
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Radius 1 km sekeliling Anda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${assets.length} Tiang',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoadingLocation)
                const Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Memperbarui posisi GPS...',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
