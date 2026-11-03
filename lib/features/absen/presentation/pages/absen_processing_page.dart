import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/watermark_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/absen_location_entity.dart';
import '../cubit/absen_submit_cubit.dart';
import '../cubit/absen_submit_state.dart';
import 'liveness_page.dart';

class AbsenProcessingPage extends StatefulWidget {
  final String type; // 'MASUK' | 'KELUAR'
  final Map<String, dynamic>? shiftData;
  final AbsenLocationEntity? absenLocation;

  const AbsenProcessingPage({
    super.key,
    required this.type,
    this.shiftData,
    this.absenLocation,
  });

  @override
  State<AbsenProcessingPage> createState() => _AbsenProcessingPageState();
}

class _AbsenProcessingPageState extends State<AbsenProcessingPage> {
  File? _watermarkedPicture;
  List<Map<String, dynamic>>? _faceProps;
  int _failedAttempt = 0;
  bool _isProcessingWatermark = false;

  Position? _capturedPosition;
  String _locationName = 'Lokasi Presensi';

  @override
  void initState() {
    super.initState();
    // Buka Liveness Detection pertama kali setelah widget terpasang di layar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLivenessFlow();
    });
  }

  Future<void> _startLivenessFlow() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => LivenessPage(initialFailedAttempt: _failedAttempt),
      ),
    );

    // Jika pengguna membatalkan/menutup kamera sebelum selesai
    if (result == null) {
      if (_watermarkedPicture == null && mounted) {
        context.pop();
      }
      return;
    }

    final File rawPhoto = result['photoFile'] as File;
    final List<Map<String, dynamic>> props =
        result['faceProps'] as List<Map<String, dynamic>>;
    final int attempts = result['failedAttempt'] as int? ?? 0;

    setState(() {
      _isProcessingWatermark = true;
      _failedAttempt = attempts;
      _faceProps = props;
    });

    try {
      // 1. Ambil posisi GPS akurat saat foto diambil
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      _capturedPosition = position;

      // 2. Tentukan nama lokasi (dari koordinat terdekat atau Gardu Induk)
      if (widget.absenLocation != null &&
          widget.absenLocation!.coordinates.isNotEmpty) {
        _locationName = widget.absenLocation!.coordinates.first.nama;
      } else {
        _locationName =
            'Lat: ${position.latitude.toStringAsFixed(5)}, Long: ${position.longitude.toStringAsFixed(5)}';
      }

      // 3. Ambil nama petugas yang sedang login
      String? userName;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        userName = '${authState.user.namaLengkap} (${authState.user.nip})';
      }

      // 4. Tambahkan Watermark Proporsional ke Foto
      // ignore: unused_local_variable
      final watermarkedFile = await WatermarkService.addWatermark(
        imageFile: rawPhoto,
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        address: _locationName,
        userName: userName,
      );

      if (!mounted) return;
      setState(() {
        _watermarkedPicture = rawPhoto;
        _isProcessingWatermark = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingWatermark = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memproses watermark: $e')));
    }
  }

  void _onAbsenPressed(BuildContext context) {
    if (_watermarkedPicture == null || _capturedPosition == null) return;

    context.read<AbsenSubmitCubit>().submitAbsen(
      type: widget.type,
      pictureFile: _watermarkedPicture!,
      latitude: _capturedPosition!.latitude,
      longitude: _capturedPosition!.longitude,
      failedAttempt: _failedAttempt,
      faceProps: _faceProps ?? [],
      address: _locationName,
      shiftData: widget.shiftData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AbsenSubmitCubit>(),
      child: BlocConsumer<AbsenSubmitCubit, AbsenSubmitState>(
        listener: (context, state) {
          if (state is AbsenSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Kembali ke halaman absen dengan sinyal refresh
            context.pop(true);
          } else if (state is AbsenSubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isSubmitting = state is AbsenSubmitLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.type == 'MASUK'
                    ? 'Verifikasi Absen Masuk'
                    : 'Verifikasi Absen Keluar',
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // Area Pratinjau Foto
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: _isProcessingWatermark
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Membubuhkan watermark pada foto...'),
                                  ],
                                )
                              : _watermarkedPicture != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _watermarkedPicture!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const Text('Menunggu pengambilan foto...'),
                        ),
                      ),
                    ),

                    // Tombol Ambil Ulang
                    if (_watermarkedPicture != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Ambil Ulang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            onPressed: isSubmitting ? null : _startLivenessFlow,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Bar Tombol Aksi Bawah (Batal & Absen)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, -2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () => context.pop(),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Absen',
                              isLoading: isSubmitting,
                              onPressed:
                                  (_watermarkedPicture == null || isSubmitting)
                                  ? null
                                  : () => _onAbsenPressed(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Modal Blocker Loading saat pengiriman data
                if (isSubmitting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Absen sedang diproses...',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
