import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/absen_repository.dart';
import 'absen_submit_state.dart';

class AbsenSubmitCubit extends Cubit<AbsenSubmitState> {
  final AbsenRepository repository;
  final NotificationService notificationService;

  AbsenSubmitCubit({
    required this.repository,
    required this.notificationService,
  }) : super(AbsenSubmitInitial());

  Future<void> submitAbsen({
    required String type,
    required File pictureFile,
    required double latitude,
    required double longitude,
    required int failedAttempt,
    required List<Map<String, dynamic>> faceProps,
    String? address,
    Map<String, dynamic>? shiftData,
    Map<String, dynamic>? extraData,
  }) async {
    emit(AbsenSubmitLoading());

    // Filter extraData to ensure internal/local shift fields are never sent
    final Map<String, dynamic>? sanitizedExtraData = extraData != null
        ? (Map<String, dynamic>.from(extraData)..remove('shift')..remove('dataShift'))
        : null;

    final result = await repository.submitAbsen(
      type: type,
      pictureFile: pictureFile,
      latitude: latitude,
      longitude: longitude,
      failedAttempt: failedAttempt,
      faceProps: faceProps,
      address: address,
      extraData: sanitizedExtraData,
    );

    result.fold((failure) => emit(AbsenSubmitError(failure.message)), (
      data,
    ) async {
      final msgRaw = data['message'];
      final String message = msgRaw is String
          ? msgRaw
          : (msgRaw is List ? msgRaw.join('\n') : 'Absen berhasil diproses');

      // Kelola Notifikasi Clock Out otomatis
      if (type == 'MASUK') {
        final shiftEnd = _calculateShiftEndTime(shiftData);
        if (shiftEnd != null) {
          await notificationService.scheduleShiftNotifications(
            shiftEndTime: shiftEnd,
          );
        }
      } else if (type == 'KELUAR') {
        await notificationService.cancelShiftNotifications();
      }

      emit(AbsenSubmitSuccess(message: message, responseData: data));
    });
  }

  /// Menghitung jam selesai shift, termasuk penanganan shift lintas hari (overnight)
  DateTime? _calculateShiftEndTime(Map<String, dynamic>? data) {
    if (data == null) return null;
    final shift = data['shift'] as Map<String, dynamic>?;
    if (shift == null) return null;

    final int tahun = shift['tahun'] ?? DateTime.now().year;
    final int bulan = shift['bulan'] ?? DateTime.now().month;
    final int tanggal = shift['tanggal'] ?? DateTime.now().day;
    final ketentuan = shift['ketentuan'] as Map<String, dynamic>?;

    if (ketentuan == null) return null;
    final int startHour = ketentuan['startHour'] ?? 0;
    final int endHour = ketentuan['endHour'] ?? 0;
    final int endMinute = ketentuan['endMinute'] ?? 0;

    // Jika jam awal lebih besar dari jam akhir (shift malam lintas hari)
    final int targetDay = startHour > endHour ? tanggal + 1 : tanggal;
    return DateTime(tahun, bulan, targetDay, endHour, endMinute);
  }
}
