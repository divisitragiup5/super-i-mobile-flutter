import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_map_viewer.dart';
import '../cubit/yantek_cubit.dart';

class InspeksiYantekPage extends StatefulWidget {
  const InspeksiYantekPage({super.key});

  @override
  State<InspeksiYantekPage> createState() => _InspeksiYantekPageState();
}

class _InspeksiYantekPageState extends State<InspeksiYantekPage> {
  double _lat = -6.2;
  double _lng = 106.8;

  @override
  void initState() {
    super.initState();
    _initLiveLocation();
  }

  Future<void> _initLiveLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
        });
        context.read<YantekCubit>().fetchNearbyAssets(lat: _lat, lng: _lng);
      }
    } catch (_) {
      if (mounted) {
        context.read<YantekCubit>().fetchNearbyAssets(lat: _lat, lng: _lng);
      }
    }
  }

  void _showAssetModal(BuildContext context, dynamic asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.idAsset,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      asset.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Inspeksi Terakhir:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Status: ${asset.lastInspeksi?.status ?? "Belum ada inspeksi"}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_task),
                label: const Text('Isi Form Inspeksi Yantek'),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push(
                    AppRoutes.inspeksiYantekInspeksiForm,
                    extra: {
                      'sutmId': asset.id.toString(),
                      'idAsset': asset.idAsset,
                      'nama': asset.nama,
                      'latitude': asset.latitude.toString(),
                      'longitude': asset.longitude.toString(),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspeksi YANTEK'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<YantekCubit, YantekState>(
        builder: (context, state) {
          if (state is YantekLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final assets = state is YantekLoaded ? state.assets : [];

          final pins = assets
              .map((a) => MapPinItem(
                    id: a.id.toString(),
                    title: a.nama,
                    subtitle: a.idAsset,
                    latitude: a.latitude,
                    longitude: a.longitude,
                    color: AppColors.primary,
                  ))
              .toList();

          return Stack(
            children: [
              FieldMapViewer(
                pins: pins,
                height: double.infinity,
                onPinSelected: (pin) {
                  final asset = assets.firstWhere(
                    (a) => a.id.toString() == pin.id,
                    orElse: () => null,
                  );
                  if (asset != null) {
                    _showAssetModal(context, asset);
                  }
                },
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ditemukan ${assets.length} tiang dalam radius 1 km',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _initLiveLocation,
                      ),
                    ],
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
