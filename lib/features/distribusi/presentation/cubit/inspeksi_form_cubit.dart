import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/local_database.dart';
import '../../data/models/sutm_inspection_payload.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class InspeksiFormState {}

class InspeksiFormInitial extends InspeksiFormState {}

class InspeksiFormLoaded extends InspeksiFormState {
  final Map<String, dynamic> formValues;
  final Map<String, dynamic> fileAttachments; // File or String (URL)
  final int activeStep;
  final int elapsedSeconds;
  final bool isDraftSaved;
  final bool isReadOnly;
  final Map<String, dynamic>? rawInspectionDetail;

  InspeksiFormLoaded({
    required this.formValues,
    required this.fileAttachments,
    this.activeStep = 0,
    this.elapsedSeconds = 0,
    this.isDraftSaved = false,
    this.isReadOnly = false,
    this.rawInspectionDetail,
  });

  InspeksiFormLoaded copyWith({
    Map<String, dynamic>? formValues,
    Map<String, dynamic>? fileAttachments,
    int? activeStep,
    int? elapsedSeconds,
    bool? isDraftSaved,
    bool? isReadOnly,
    Map<String, dynamic>? rawInspectionDetail,
  }) {
    return InspeksiFormLoaded(
      formValues: formValues ?? this.formValues,
      fileAttachments: fileAttachments ?? this.fileAttachments,
      activeStep: activeStep ?? this.activeStep,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      rawInspectionDetail: rawInspectionDetail ?? this.rawInspectionDetail,
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

  void initForm(String workOrderSutmItemId, {Map<String, dynamic>? initialData, bool isReadOnly = false}) async {
    if (initialData != null && initialData.isNotEmpty) {
      _applyInspectionData(initialData, isReadOnly: isReadOnly);
      return;
    }

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
        isReadOnly: isReadOnly,
      ));
    } else {
      emit(InspeksiFormLoaded(
        formValues: {},
        fileAttachments: {},
        activeStep: 0,
        elapsedSeconds: 0,
        isDraftSaved: false,
        isReadOnly: isReadOnly,
      ));
    }
  }

  Future<void> loadRemoteInspection(String workOrderSutmItemId, {bool isReadOnly = false}) async {
    emit(InspeksiFormSubmitting());
    final result = await repository.getWorkOrderInspeksiRiwayatDetail(workOrderSutmItemId);
    result.fold(
      (failure) {
        emit(InspeksiFormError(message: failure.message));
      },
      (data) {
        _applyInspectionData(data, isReadOnly: isReadOnly);
      },
    );
  }

  void _applyInspectionData(Map<String, dynamic> rawData, {bool isReadOnly = false}) {
    final values = <String, dynamic>{};
    final attachments = <String, dynamic>{};

    // Ambil detail inspeksi dari raw data
    final detail = rawData['data'] is Map<String, dynamic>
        ? rawData['data'] as Map<String, dynamic>
        : (rawData['items'] is List && (rawData['items'] as List).isNotEmpty
            ? (rawData['items'] as List).first as Map<String, dynamic>
            : rawData);

    // 1. Tiang
    if (detail['jenisTiang'] != null) values['1_jenis_tiang'] = detail['jenisTiang'].toString();
    if (detail['tinggiTiang'] != null) values['1_tinggi_tiang'] = detail['tinggiTiang'].toString();
    if (detail['identitasTiang'] != null) values['1_identitas_tiang'] = detail['identitasTiang'].toString();

    if (detail['kondisiTiang'] is Map) {
      final kt = detail['kondisiTiang'] as Map;
      final list = kt['kondisi'];
      if (list is List) {
        values['1_kondisi_tiang'] = list.join(', ');
      } else if (list != null) {
        values['1_kondisi_tiang'] = list.toString();
      }
      if (kt['fotoUrl'] != null) {
        attachments['kondisiTiangFoto'] = kt['fotoUrl'].toString();
      }
    }

    if (detail['jenisKonstruksi'] is Map) {
      final jk = detail['jenisKonstruksi'] as Map;
      if (jk['jenis'] != null) values['1_jenis_konstruksi'] = jk['jenis'].toString();
      if (jk['fotoUrl'] != null) attachments['jenisKonstruksiFoto'] = jk['fotoUrl'].toString();
    }

    // 2. Penghantar
    if (detail['jenisKonduktor'] != null) values['2_jenis_konduktor'] = detail['jenisKonduktor'].toString();
    if (detail['ukuranKonduktor'] != null) values['2_ukuran_konduktor'] = detail['ukuranKonduktor'].toString();
    if (detail['jenisKonduktorFotoUrl'] != null) {
      attachments['jenisKonduktorFoto'] = detail['jenisKonduktorFotoUrl'].toString();
    }

    if (detail['konduktor'] is List) {
      for (final k in detail['konduktor'] as List) {
        if (k is Map) {
          final fasa = (k['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty) {
            values['2_konduktor_fasa_$fasa'] = k['kondisi']?.toString() ?? 'Baik';
            if (k['fotoUrl'] != null) {
              attachments['konduktorFoto${fasa.toUpperCase()}'] = k['fotoUrl'].toString();
            }
          }
        }
      }
    }

    if (detail['sambungan'] is List) {
      for (final s in detail['sambungan'] as List) {
        if (s is Map) {
          final fasa = (s['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty) {
            values['2_sambungan_fasa_$fasa'] = s['kondisi']?.toString() ?? 'Tidak Ada';
            if (s['fotoUrl'] != null) {
              attachments['sambunganFoto${fasa.toUpperCase()}'] = s['fotoUrl'].toString();
            }
          }
        }
      }
    }

    if (detail['terminasi'] is List) {
      for (final t in detail['terminasi'] as List) {
        if (t is Map) {
          final fasa = (t['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty) {
            values['2_terminasi_fasa_$fasa'] = t['kondisi']?.toString() ?? 'Tidak Ada';
            if (t['fotoUrl'] != null) {
              attachments['terminasiFoto${fasa.toUpperCase()}'] = t['fotoUrl'].toString();
            }
          }
        }
      }
    }

    // 3. Isolator
    final jenisKonstr = values['1_jenis_konstruksi']?.toString() ?? 'TM 1';
    final suffix = (jenisKonstr == 'TM 1' || jenisKonstr == 'TM 3') ? 'tm_1_3' : 'tm_5';

    if (detail['jenisIsolator'] is List && (detail['jenisIsolator'] as List).isNotEmpty) {
      final ji = (detail['jenisIsolator'] as List).first;
      if (ji is Map && ji['jenis'] != null) {
        values['3_jenis_isolator_$suffix'] = ji['jenis'].toString();
      }
    }

    if (detail['isolatorTumpu'] is List) {
      for (final it in detail['isolatorTumpu'] as List) {
        if (it is Map) {
          final fasa = (it['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty) {
            values['3_isolator_tumpu_${suffix}_fasa_$fasa'] = it['kondisi']?.toString() ?? 'Baik';
            if (it['jumlahTemuan'] != null) {
              values['3_isolator_tumpu_${suffix}_fasa_${fasa}_jumlah_temuan'] = it['jumlahTemuan'].toString();
            }
            if (it['fotoUrl'] != null) {
              attachments['isolatorTumpuFoto${fasa.toUpperCase()}'] = it['fotoUrl'].toString();
            }
          }
        }
      }
    }

    if (detail['topTies'] is List) {
      for (final tt in detail['topTies'] as List) {
        if (tt is Map) {
          final fasa = (tt['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty) {
            values['3_top_ties_${suffix}_fasa_$fasa'] = tt['kondisi']?.toString() ?? 'Baik';
            if (tt['jumlahTemuan'] != null) {
              values['3_top_ties_${suffix}_fasa_${fasa}_jumlah_temuan'] = tt['jumlahTemuan'].toString();
            }
            if (tt['fotoUrl'] != null) {
              attachments['topTiesFoto${fasa.toUpperCase()}'] = tt['fotoUrl'].toString();
            }
          }
        }
      }
    }

    if (detail['crossArm'] is Map) {
      final ca = detail['crossArm'] as Map;
      if (ca['kondisi'] != null) values['3_cross_arm_$suffix'] = ca['kondisi'].toString();
      if (ca['fotoUrl'] != null) attachments['crossArmFoto'] = ca['fotoUrl'].toString();
    }

    if (suffix == 'tm_1_3') {
      if (detail['armTie'] is Map) {
        final at = detail['armTie'] as Map;
        if (at['kondisi'] != null) values['3_arm_tie_tm_1_3'] = at['kondisi'].toString();
        if (at['fotoUrl'] != null) attachments['armTieFoto'] = at['fotoUrl'].toString();
      }
    } else {
      if (detail['isolatorTarik'] is List) {
        for (final it in detail['isolatorTarik'] as List) {
          if (it is Map) {
            final fasa = (it['fasa'] ?? '').toString().toLowerCase();
            if (fasa.isNotEmpty) {
              values['3_isolator_tarik_tm_5_fasa_$fasa'] = it['kondisi']?.toString() ?? 'Baik';
              if (it['fotoUrl'] != null) {
                attachments['isolatorTarikFoto${fasa.toUpperCase()}'] = it['fotoUrl'].toString();
              }
            }
          }
        }
      }
      if (detail['sambunganJumper'] is List) {
        for (final sj in detail['sambunganJumper'] as List) {
          if (sj is Map) {
            final fasa = (sj['fasa'] ?? '').toString().toLowerCase();
            if (fasa.isNotEmpty) {
              values['3_sambungan_jumper_tm_5_fasa_$fasa'] = sj['jenis']?.toString() ?? 'Tidak Ada';
              if (sj['fotoUrl'] != null) {
                attachments['sambunganJumperFoto${fasa.toUpperCase()}'] = sj['fotoUrl'].toString();
              }
            }
          }
        }
      }
    }

    // 4. Proteksi & Pembumian
    if (detail['gswLetak'] != null) values['4_gsw'] = detail['gswLetak'].toString();
    if (detail['gswKondisi'] != null) values['4_kondisi_gsw'] = detail['gswKondisi'].toString();
    if (detail['gswFotoUrl'] != null) attachments['gswFoto'] = detail['gswFotoUrl'].toString();
    if (detail['kondisiGswFotoUrl'] != null) attachments['kondisiGswFoto'] = detail['kondisiGswFotoUrl'].toString();

    final hasArr = (detail['arrester'] is List && (detail['arrester'] as List).any((a) => (a is Map && a['jenis'] != null && a['jenis'] != 'Tidak Ada')));
    values['4_has_arrester'] = hasArr ? 'Ada' : 'Tidak Ada';

    if (detail['arrester'] is List) {
      for (final a in detail['arrester'] as List) {
        if (a is Map) {
          final fasa = (a['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty && a['jenis'] != null) {
            values['4_jenis_arrester_fasa_$fasa'] = a['jenis'].toString();
          }
        }
      }
    }
    if (detail['kondisiArrester'] is List) {
      for (final ka in detail['kondisiArrester'] as List) {
        if (ka is Map) {
          final fasa = (ka['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty && ka['kondisi'] != null) {
            values['4_kondisi_arrester_fasa_$fasa'] = ka['kondisi'].toString();
            if (ka['fotoUrl'] != null) {
              attachments['kondisiArresterFoto${fasa.toUpperCase()}'] = ka['fotoUrl'].toString();
            }
          }
        }
      }
    }

    if (detail['jumperArrester'] is Map) {
      final ja = detail['jumperArrester'] as Map;
      if (ja['kondisi'] != null) values['4_jumper_arrester'] = ja['kondisi'].toString();
      if (ja['fotoUrl'] != null) attachments['jumperArresterFoto'] = ja['fotoUrl'].toString();
    }

    if (detail['kawatPembumian'] is Map) {
      final kp = detail['kawatPembumian'] as Map;
      if (kp['kondisi'] != null) values['4_kawat_pembumian'] = kp['kondisi'].toString();
      if (kp['fotoUrl'] != null) attachments['kawatPembumianFoto'] = kp['fotoUrl'].toString();
    }
    if (detail['ukurKawatPembumian'] != null) {
      values['4_hasil_ukur_kawat_pembumian'] = detail['ukurKawatPembumian'].toString();
    }
    if (detail['ukurKawatPembumianFotoUrl'] != null) {
      attachments['ukurKawatPembumianFoto'] = detail['ukurKawatPembumianFotoUrl'].toString();
    }

    if (detail['grounding'] is Map) {
      final g = detail['grounding'] as Map;
      if (g['kondisi'] != null) values['4_grounding'] = g['kondisi'].toString();
      if (g['fotoUrl'] != null) attachments['groundingFoto'] = g['fotoUrl'].toString();
    }
    if (detail['ukurGrounding'] != null) {
      values['4_hasil_ukur_grounding'] = detail['ukurGrounding'].toString();
    }
    if (detail['ukurGroundingFotoUrl'] != null) {
      attachments['ukurGroundingFoto'] = detail['ukurGroundingFotoUrl'].toString();
    }

    // 5. Konstruksi Penopang
    if (detail['konstruksiPenopang'] is Map) {
      final kp = detail['konstruksiPenopang'] as Map;
      if (kp['jenis'] != null) values['5_penopang_jenis'] = kp['jenis'].toString();
      if (kp['kondisi'] != null) values['5_penopang_kondisi'] = kp['kondisi'].toString();
      if (kp['fotoUrl'] != null) attachments['konstruksiPenopangFoto'] = kp['fotoUrl'].toString();
      if (kp['kondisiFotoUrl'] != null) attachments['kondisiKonstruksiPenopangFoto'] = kp['kondisiFotoUrl'].toString();
    }
    if (detail['kondisiSteelWire'] is Map) {
      final sw = detail['kondisiSteelWire'] as Map;
      if (sw['kondisi'] != null) values['5_kondisi_steel_wire'] = sw['kondisi'].toString();
      if (sw['fotoUrl'] != null) attachments['kondisiSteelWireFoto'] = sw['fotoUrl'].toString();
    }
    if (detail['pondasi'] is Map) {
      final p = detail['pondasi'] as Map;
      if (p['kondisi'] != null) values['5_pondasi'] = p['kondisi'].toString();
      if (p['fotoUrl'] != null) attachments['pondasiFoto'] = p['fotoUrl'].toString();
    }

    // 6. Hubung
    if (detail['fco'] is List) {
      for (final f in detail['fco'] as List) {
        if (f is Map) {
          final fasa = (f['fasa'] ?? '').toString().toLowerCase();
          if (fasa.isNotEmpty && f['kondisi'] != null) {
            values['6_fco_fasa_$fasa'] = f['kondisi'].toString();
            if (f['fotoUrl'] != null) attachments['fcoFoto${fasa.toUpperCase()}'] = f['fotoUrl'].toString();
          }
        }
      }
    }
    if (detail['sambunganFCO'] is Map) {
      final sf = detail['sambunganFCO'] as Map;
      if (sf['jenis'] != null) values['6_sambungan_fco'] = sf['jenis'].toString();
      if (sf['fotoUrl'] != null) attachments['sambunganFCOFoto'] = sf['fotoUrl'].toString();
    }
    if (detail['lbsKonvensional'] is Map) {
      final lk = detail['lbsKonvensional'] as Map;
      if (lk['kondisi'] != null) values['6_lbs_konvensional'] = lk['kondisi'].toString();
      if (lk['fotoUrl'] != null) attachments['lbsKonvensionalFoto'] = lk['fotoUrl'].toString();
    }
    if (detail['lbsRemote'] is Map) {
      final lr = detail['lbsRemote'] as Map;
      if (lr['kondisi'] != null) values['6_lbs_remote_motorized'] = lr['kondisi'].toString();
      if (lr['fotoUrl'] != null) attachments['lbsRemoteFoto'] = lr['fotoUrl'].toString();
    }
    if (detail['recloser'] is Map) {
      final rc = detail['recloser'] as Map;
      if (rc['kondisi'] != null) values['6_recloser'] = rc['kondisi'].toString();
      if (rc['fotoUrl'] != null) attachments['recloserFoto'] = rc['fotoUrl'].toString();
    }

    // 7. ROW
    if (detail['row'] is List) {
      final rows = <Map<String, dynamic>>[];
      final rawRowList = detail['row'] as List;
      for (int i = 0; i < rawRowList.length; i++) {
        final r = rawRowList[i];
        if (r is Map) {
          final rowMap = Map<String, dynamic>.from(r);
          rows.add(rowMap);
          if (r['fotoUrl'] != null) {
            attachments['rowFoto$i'] = r['fotoUrl'].toString();
          }
        }
      }
      values['7_rows'] = rows;
    }

    emit(InspeksiFormLoaded(
      formValues: values,
      fileAttachments: attachments,
      activeStep: 0,
      elapsedSeconds: 0,
      isDraftSaved: true,
      isReadOnly: isReadOnly,
      rawInspectionDetail: detail,
    ));
  }

  void updateField(String key, dynamic value, String workOrderSutmItemId) {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;
    final updatedValues = Map<String, dynamic>.from(current.formValues);
    updatedValues[key] = value;

    emit(current.copyWith(formValues: updatedValues));
    _autoSaveDraft(workOrderSutmItemId, updatedValues, current.activeStep, current.elapsedSeconds);
  }

  void updateAttachment(String key, dynamic fileOrUrl, String workOrderSutmItemId) {
    if (state is! InspeksiFormLoaded) return;
    final current = state as InspeksiFormLoaded;
    final updatedFiles = Map<String, dynamic>.from(current.fileAttachments);
    if (fileOrUrl == null) {
      updatedFiles.remove(key);
    } else {
      updatedFiles[key] = fileOrUrl;
    }

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
        if (workOrderSutmItemId != null) {
          await LocalDatabase.instance.deleteSutmDraft(workOrderSutmItemId.toString());
        }
        emit(InspeksiFormSuccess(message: 'Inspeksi SUTM berhasil disimpan!'));
      },
    );
  }

  Future<void> submitValidation({
    required String role,
    required int inspectionId,
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

    final result = await repository.validateInspeksi(
      role: role,
      id: inspectionId,
      formData: formData,
    );
    result.fold(
      (failure) => emit(InspeksiFormError(message: failure.message)),
      (_) async {
        emit(InspeksiFormSuccess(message: 'Validasi inspeksi berhasil dikirim!'));
      },
    );
  }

  Future<void> approveInspection({
    required String role,
    required int inspectionId,
  }) async {
    emit(InspeksiFormSubmitting());
    final result = await repository.approveInspeksi(role: role, id: inspectionId);
    result.fold(
      (failure) => emit(InspeksiFormError(message: failure.message)),
      (_) => emit(InspeksiFormSuccess(message: 'Inspeksi berhasil disetujui!')),
    );
  }

  Future<void> rejectInspection({
    required String role,
    required int inspectionId,
    required String reason,
  }) async {
    emit(InspeksiFormSubmitting());
    final result = await repository.rejectInspeksi(
      role: role,
      id: inspectionId,
      reason: reason,
    );
    result.fold(
      (failure) => emit(InspeksiFormError(message: failure.message)),
      (_) => emit(InspeksiFormSuccess(message: 'Inspeksi berhasil ditolak!')),
    );
  }
}
