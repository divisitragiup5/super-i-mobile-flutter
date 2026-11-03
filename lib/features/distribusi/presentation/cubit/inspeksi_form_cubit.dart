import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/local_database.dart';
import '../../data/models/sutm_inspection_payload.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class InspeksiFormState {}

class InspeksiFormInitial extends InspeksiFormState {}

class InspeksiFormLoaded extends InspeksiFormState {
  final Map<String, dynamic> formValues;
  final Map<String, File?> fileAttachments;
  final int activeStep;
  final int elapsedSeconds;
  final bool isDraftSaved;

  InspeksiFormLoaded({
    required this.formValues,
    required this.fileAttachments,
    this.activeStep = 0,
    this.elapsedSeconds = 0,
    this.isDraftSaved = false,
  });

  InspeksiFormLoaded copyWith({
    Map<String, dynamic>? formValues,
    Map<String, File?>? fileAttachments,
    int? activeStep,
    int? elapsedSeconds,
    bool? isDraftSaved,
  }) {
    return InspeksiFormLoaded(
      formValues: formValues ?? this.formValues,
      fileAttachments: fileAttachments ?? this.fileAttachments,
      activeStep: activeStep ?? this.activeStep,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
    );
  }
}

class InspeksiFormSubmitting extends InspeksiFormState {}

class InspeksiFormSuccess extends InspeksiFormState {
  final String message;

  InspeksiFormSuccess({required this.message});
}

class InspeksiFormError extends InspeksiFormState {
  final String message;

  InspeksiFormError({required this.message});
}

class InspeksiFormCubit extends Cubit<InspeksiFormState> {
  final SutmRepository repository;

  InspeksiFormCubit({required this.repository}) : super(InspeksiFormInitial());

  void initForm(String workOrderSutmItemId) async {
    // Cek apakah ada draft lokal di database SQLite
    final draft = await LocalDatabase.instance.getSutmDraft(workOrderSutmItemId);
    if (draft != null && draft.isNotEmpty) {
      final savedData = draft['data'] as Map<String, dynamic>? ?? {};
      final savedValues = savedData['formValues'] as Map<String, dynamic>? ?? {};
      final savedStep = savedData['activeStep'] as int? ?? 0;
      final savedElapsed = savedData['elapsedSeconds'] as int? ?? 0;

      emit(InspeksiFormLoaded(
        formValues: Map<String, dynamic>.from(savedValues),
        fileAttachments: {},
        activeStep: savedStep,
        elapsedSeconds: savedElapsed,
        isDraftSaved: true,
      ));
    } else {
      emit(InspeksiFormLoaded(
        formValues: {},
        fileAttachments: {},
        activeStep: 0,
        elapsedSeconds: 0,
        isDraftSaved: false,
      ));
    }
  }

  void updateField(String key, dynamic value, String workOrderSutmItemId) {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;
    final updatedValues = Map<String, dynamic>.from(current.formValues);
    updatedValues[key] = value;

    emit(current.copyWith(formValues: updatedValues));
    _autoSaveDraft(workOrderSutmItemId, updatedValues, current.activeStep, current.elapsedSeconds);
  }

  void updateAttachment(String key, File? file, String workOrderSutmItemId) {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;
    final updatedFiles = Map<String, File?>.from(current.fileAttachments);
    updatedFiles[key] = file;

    emit(current.copyWith(fileAttachments: updatedFiles));
  }

  void setStep(int step, String workOrderSutmItemId) {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;
    emit(current.copyWith(activeStep: step));
    _autoSaveDraft(workOrderSutmItemId, current.formValues, step, current.elapsedSeconds);
  }

  void updateTimer(int seconds, String workOrderSutmItemId) {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;
    emit(current.copyWith(elapsedSeconds: seconds));
  }

  Future<void> _autoSaveDraft(
    String workOrderSutmItemId,
    Map<String, dynamic> values,
    int step,
    int elapsed,
  ) async {
    try {
      await LocalDatabase.instance.saveSutmDraft(
        workOrderSutmItemId: workOrderSutmItemId,
        data: {
          'formValues': values,
          'activeStep': step,
          'elapsedSeconds': elapsed,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {}
  }

  Future<void> submitForm({
    required int? workOrderSutmItemId,
    int? sutmId,
    required double latitude,
    required double longitude,
    required DateTime startTime,
  }) async {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;

    emit(InspeksiFormSubmitting());

    final formData = SutmInspectionPayload.buildFormData(
      formValues: current.formValues,
      workOrderSutmItemId: workOrderSutmItemId,
      sutmId: sutmId,
      latitude: latitude,
      longitude: longitude,
      startTime: startTime,
      endTime: DateTime.now(),
      fileAttachments: current.fileAttachments,
    );

    final result = await repository.submitInspeksi(formData);
    result.fold(
      (failure) => emit(InspeksiFormError(message: failure.message)),
      (_) async {
        // Hapus draft SQLite jika sukses terkirim
        if (workOrderSutmItemId != null) {
          await LocalDatabase.instance.deleteSutmDraft(workOrderSutmItemId.toString());
        }
        emit(InspeksiFormSuccess(message: 'Inspeksi SUTM berhasil disimpan!'));
      },
    );
  }
}
