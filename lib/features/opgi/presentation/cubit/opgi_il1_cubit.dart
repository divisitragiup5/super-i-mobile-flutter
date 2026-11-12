import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/opgi_il1_model.dart';
import '../../domain/repositories/opgi_repository.dart';

abstract class OpgiIl1State extends Equatable {
  const OpgiIl1State();
  @override
  List<Object?> get props => [];
}

class OpgiIl1Initial extends OpgiIl1State {}
class OpgiIl1Loading extends OpgiIl1State {}

class Il1KubikelLoaded extends OpgiIl1State {
  final List<Il1KubikelItem> items;
  final List<Map<String, dynamic>> localDrafts;
  const Il1KubikelLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class Il1KubikelTodayLoaded extends OpgiIl1State {
  final Il1KubikelTodayDetailModel? item;
  const Il1KubikelTodayLoaded(this.item);
  @override
  List<Object?> get props => [item];
}

class Il1TrafoPsLoaded extends OpgiIl1State {
  final List<Il1TrafoPsItem> items;
  final List<Map<String, dynamic>> localDrafts;
  const Il1TrafoPsLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class Il1TrafoPsTodayLoaded extends OpgiIl1State {
  final Il1TrafoPsTodayDetailModel? item;
  const Il1TrafoPsTodayLoaded(this.item);
  @override
  List<Object?> get props => [item];
}

class Il1SipilLoaded extends OpgiIl1State {
  final List<Il1SipilItem> items;
  final List<Map<String, dynamic>> localDrafts;
  const Il1SipilLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class Il1SipilTodayLoaded extends OpgiIl1State {
  final Il1SipilTodayDetailModel? item;
  const Il1SipilTodayLoaded(this.item);
  @override
  List<Object?> get props => [item];
}

class OpgiBatchProgress extends OpgiIl1State {
  final int completed;
  final int total;
  const OpgiBatchProgress({required this.completed, required this.total});
  @override
  List<Object?> get props => [completed, total];
}

class OpgiIl1Success extends OpgiIl1State {
  final String message;
  const OpgiIl1Success(this.message);
  @override
  List<Object?> get props => [message];
}

class OpgiIl1Error extends OpgiIl1State {
  final String message;
  const OpgiIl1Error(this.message);
  @override
  List<Object?> get props => [message];
}

class OpgiIl1Cubit extends Cubit<OpgiIl1State> {
  final OpgiRepository _repository;

  // In-memory caches for IL1 Kubikel
  List<Il1KubikelItem> _cachedKubikelList = [];
  List<Map<String, dynamic>> _cachedKubikelDrafts = [];
  Il1KubikelTodayDetailModel? _cachedKubikelToday;

  List<Il1KubikelItem> get cachedKubikelList => _cachedKubikelList;
  List<Map<String, dynamic>> get cachedKubikelDrafts => _cachedKubikelDrafts;
  Il1KubikelTodayDetailModel? get cachedKubikelToday => _cachedKubikelToday;

  // In-memory caches for IL1 Trafo PS
  List<Il1TrafoPsItem> _cachedTrafoPsList = [];
  List<Map<String, dynamic>> _cachedTrafoPsDrafts = [];
  Il1TrafoPsTodayDetailModel? _cachedTrafoPsToday;

  List<Il1TrafoPsItem> get cachedTrafoPsList => _cachedTrafoPsList;
  List<Map<String, dynamic>> get cachedTrafoPsDrafts => _cachedTrafoPsDrafts;
  Il1TrafoPsTodayDetailModel? get cachedTrafoPsToday => _cachedTrafoPsToday;

  // In-memory caches for IL1 Sipil
  List<Il1SipilItem> _cachedSipilList = [];
  List<Map<String, dynamic>> _cachedSipilDrafts = [];
  Il1SipilTodayDetailModel? _cachedSipilToday;

  List<Il1SipilItem> get cachedSipilList => _cachedSipilList;
  List<Map<String, dynamic>> get cachedSipilDrafts => _cachedSipilDrafts;
  Il1SipilTodayDetailModel? get cachedSipilToday => _cachedSipilToday;

  OpgiIl1Cubit(this._repository) : super(OpgiIl1Initial());

  // ==========================================
  // 1. IL1 KUBIKEL
  // ==========================================

  Future<void> loadKubikel(
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final items = await _repository.getIl1KubikelInput(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedKubikelList = items;

      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'il1-kubikel');
      } catch (e) {
        debugPrint('[DB DRAFT ERROR] $e');
      }
      _cachedKubikelDrafts = drafts;

      emit(Il1KubikelLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> loadKubikelToday(
    int penyulangId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final item = await _repository.getIl1KubikelToday(
        penyulangId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedKubikelToday = item;
      emit(Il1KubikelTodayLoaded(item));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> submitKubikelSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    dynamic fotoAnomali,
    int? draftId,
    String timezone = 'Asia/Jakarta',
  }) async {
    emit(OpgiIl1Loading());
    try {
      final res = await _repository.submitIl1KubikelSingle(
        data: data,
        fotoBuktiInspeksi: fotoBuktiInspeksi,
        fotoAnomali: fotoAnomali,
        timezone: timezone,
      );

      if (draftId != null) {
        try {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          _cachedKubikelDrafts = _cachedKubikelDrafts.where((d) => d['id'] != draftId).toList();
        } catch (_) {}
      }

      final penyulangId = int.tryParse(data['penyulangId']?.toString() ?? '');
      final resPayload = res ?? <String, dynamic>{...data, 'id': 999999};

      // 1. Optimistic update in-memory kubikel list
      if (penyulangId != null) {
        _cachedKubikelList = _cachedKubikelList.map((item) {
          if (item.id == penyulangId) {
            return item.copyWith(
              last: resPayload,
              il1: [resPayload],
              status: resPayload['status']?.toString(),
            );
          }
          return item;
        }).toList();
      }

      // 2. Optimistic update SQLite api_cache
      try {
        if (penyulangId != null) {
          await LocalDatabase.instance.optimisticAddIl1Kubikel(penyulangId, resPayload);
        }
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiIl1Success('Data IL1 Kubikel berhasil disimpan'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> updateKubikel({
    required int id,
    required Map<String, dynamic> data,
    dynamic fotoAnomali,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final res = await _repository.updateIl1Kubikel(
        id,
        data,
        fotoAnomali: fotoAnomali,
      );
      final updatePayload = res ?? <String, dynamic>{...data, 'id': id};

      // 1. Optimistic update in-memory today detail
      if (_cachedKubikelToday != null && _cachedKubikelToday!.id == id) {
        final merged = <String, dynamic>{
          ..._cachedKubikelToday!.toJson(),
          ...updatePayload,
        };
        _cachedKubikelToday = Il1KubikelTodayDetailModel.fromJson(merged);
      }

      // 2. Optimistic update in-memory list
      _cachedKubikelList = _cachedKubikelList.map((item) {
        final lastId = item.last?['id'];
        if (lastId == id || '$lastId' == '$id') {
          final mergedLast = <String, dynamic>{
            ...item.last!,
            ...updatePayload,
          };
          return item.copyWith(
            last: mergedLast,
            status: mergedLast['status']?.toString(),
          );
        }
        return item;
      }).toList();

      // 3. Optimistic update SQLite api_cache
      try {
        await LocalDatabase.instance.optimisticUpdateIl1Kubikel(id, updatePayload);
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiIl1Success('Data IL1 Kubikel berhasil diperbarui'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> deleteKubikel(int id, {int? penyulangId}) async {
    // 1. Optimistic update in-memory state
    _cachedKubikelToday = null;
    emit(const Il1KubikelTodayLoaded(null));

    _cachedKubikelList = _cachedKubikelList.map((item) {
      final lastId = item.last?['id'];
      if ((penyulangId != null && item.id == penyulangId) || (lastId != null && (lastId == id || '$lastId' == '$id'))) {
        return Il1KubikelItem(
          id: item.id,
          nama: item.nama,
          kode: item.kode,
          garduIndukId: item.garduIndukId,
          garduIndukNama: item.garduIndukNama,
          garduInduk: item.garduInduk,
          rel: item.rel,
          merkKubikel: item.merkKubikel,
          trafoId: item.trafoId,
          isDisabled: item.isDisabled,
          il1: const [],
          last: null,
          lastData: null,
          status: null,
          drafted: item.drafted,
        );
      }
      return item;
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteIl1Kubikel(id);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteIl1Kubikel(id);
      emit(const OpgiIl1Success('Data IL1 Kubikel berhasil dihapus'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> batchSubmitKubikel(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');

      try {
        await _repository.submitIl1KubikelSingle(
          data: item,
          fotoBuktiInspeksi: item['fotoBuktiInspeksi'],
          fotoAnomali: item['fotoAnomali'],
        );

        if (draftId != null) {
          try {
            await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          } catch (_) {}
        }
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('[BATCH KUBIKEL ERROR] item $i: $e');
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    // Refresh after batch
    await loadKubikel(garduIndukId, forceRefresh: true);

    if (errorCount == 0) {
      emit(OpgiIl1Success('Berhasil menyimpan semua ($successCount) draft IL1 Kubikel'));
    } else {
      emit(OpgiIl1Success('Selesai: $successCount berhasil, $errorCount gagal'));
    }
  }

  Future<List<Map<String, dynamic>>> getTrafoList(int garduIndukId) async {
    return _repository.getTrafoList(garduIndukId);
  }

  Future<List<Map<String, dynamic>>> getRelList(int garduIndukId) async {
    return _repository.getRelList(garduIndukId);
  }

  // Legacy method compatibility
  Future<void> submitKubikel({
    required Map<String, dynamic> data,
    required List<XFile> files,
    int? draftId,
  }) async {
    emit(OpgiIl1Loading());
    try {
      await _repository.submitIl1Kubikel(data: data, files: files);
      if (draftId != null) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
      }
      emit(const OpgiIl1Success('Data IL1 Kubikel berhasil disimpan'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  // ==========================================
  // 2. IL1 TRAFO PS
  // ==========================================

  Future<void> loadTrafoPs(
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final items = await _repository.getIl1TrafoPsInput(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedTrafoPsList = items;

      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'il1-trafo-ps');
      } catch (e) {
        debugPrint('[DB DRAFT ERROR] $e');
      }
      _cachedTrafoPsDrafts = drafts;

      emit(Il1TrafoPsLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> loadTrafoPsToday(
    int trafoId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final item = await _repository.getIl1TrafoPsToday(
        trafoId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedTrafoPsToday = item;
      emit(Il1TrafoPsTodayLoaded(item));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> submitTrafoPsSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    int? draftId,
    String timezone = 'Asia/Jakarta',
  }) async {
    emit(OpgiIl1Loading());
    try {
      final res = await _repository.submitIl1TrafoPsSingle(
        data: data,
        fotoBuktiInspeksi: fotoBuktiInspeksi,
        timezone: timezone,
      );

      if (draftId != null) {
        try {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          _cachedTrafoPsDrafts = _cachedTrafoPsDrafts.where((d) => d['id'] != draftId).toList();
        } catch (_) {}
      }

      final trafoId = int.tryParse(data['trafoId']?.toString() ?? '');
      final resPayload = res ?? <String, dynamic>{...data, 'id': 999999};

      // 1. Optimistic update in-memory trafo ps list
      if (trafoId != null) {
        _cachedTrafoPsList = _cachedTrafoPsList.map((item) {
          if (item.id == trafoId) {
            return item.copyWith(
              last: resPayload,
              il1TrafoPS: [resPayload],
              status: resPayload['status']?.toString(),
            );
          }
          return item;
        }).toList();
      }

      // 2. Optimistic update SQLite api_cache
      try {
        if (trafoId != null) {
          await LocalDatabase.instance.optimisticAddIl1TrafoPs(trafoId, resPayload);
        }
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiIl1Success('Data IL1 Trafo PS berhasil disimpan'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> updateTrafoPs({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final res = await _repository.updateIl1TrafoPs(id, data);
      final updatePayload = res ?? <String, dynamic>{...data, 'id': id};

      // 1. Optimistic update in-memory today detail
      if (_cachedTrafoPsToday != null && _cachedTrafoPsToday!.id == id) {
        final merged = <String, dynamic>{
          ..._cachedTrafoPsToday!.toJson(),
          ...updatePayload,
        };
        _cachedTrafoPsToday = Il1TrafoPsTodayDetailModel.fromJson(merged);
      }

      // 2. Optimistic update in-memory list
      _cachedTrafoPsList = _cachedTrafoPsList.map((item) {
        final lastId = item.last?['id'];
        if (lastId == id || '$lastId' == '$id') {
          final mergedLast = <String, dynamic>{
            ...item.last!,
            ...updatePayload,
          };
          return item.copyWith(
            last: mergedLast,
            status: mergedLast['status']?.toString(),
          );
        }
        return item;
      }).toList();

      // 3. Optimistic update SQLite api_cache
      try {
        await LocalDatabase.instance.optimisticUpdateIl1TrafoPs(id, updatePayload);
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiIl1Success('Data IL1 Trafo PS berhasil diperbarui'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> deleteTrafoPs(int id, {int? trafoId}) async {
    // 1. Optimistic update in-memory state
    _cachedTrafoPsToday = null;
    emit(const Il1TrafoPsTodayLoaded(null));

    _cachedTrafoPsList = _cachedTrafoPsList.map((item) {
      final lastId = item.last?['id'];
      if ((trafoId != null && item.id == trafoId) || (lastId != null && (lastId == id || '$lastId' == '$id'))) {
        return Il1TrafoPsItem(
          id: item.id,
          nama: item.nama,
          garduIndukId: item.garduIndukId,
          garduIndukNama: item.garduIndukNama,
          garduInduk: item.garduInduk,
          trafo: item.trafo,
          isDisabled: item.isDisabled,
          il1TrafoPS: const [],
          last: null,
          lastData: null,
          status: null,
          drafted: item.drafted,
        );
      }
      return item;
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteIl1TrafoPs(id);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteIl1TrafoPs(id);
      emit(const OpgiIl1Success('Data IL1 Trafo PS berhasil dihapus'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> batchSubmitTrafoPs(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');

      try {
        await _repository.submitIl1TrafoPsSingle(
          data: item,
          fotoBuktiInspeksi: item['fotoBuktiInspeksi'],
        );

        if (draftId != null) {
          try {
            await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          } catch (_) {}
        }
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('[BATCH TRAFO PS ERROR] item $i: $e');
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    // Refresh after batch
    await loadTrafoPs(garduIndukId, forceRefresh: true);

    if (errorCount == 0) {
      emit(OpgiIl1Success('Berhasil menyimpan semua ($successCount) draft IL1 Trafo PS'));
    } else {
      emit(OpgiIl1Success('Selesai: $successCount berhasil, $errorCount gagal'));
    }
  }

  // Legacy method compatibility
  Future<void> submitTrafoPs({
    required Map<String, dynamic> data,
    required XFile file,
    int? draftId,
  }) async {
    emit(OpgiIl1Loading());
    try {
      await _repository.submitIl1TrafoPs(data: data, file: file);
      if (draftId != null) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
      }
      emit(const OpgiIl1Success('Data IL1 Trafo PS berhasil disimpan'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  // ==========================================
  // 3. IL1 SIPIL
  // ==========================================

  Future<void> loadSipil(
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final items = await _repository.getIl1SipilInput(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedSipilList = items;

      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'il1-sipil');
      } catch (e) {
        debugPrint('[DB DRAFT ERROR] $e');
      }
      _cachedSipilDrafts = drafts;

      emit(Il1SipilLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> loadSipilToday(
    int sipilId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final item = await _repository.getIl1SipilToday(
        sipilId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedSipilToday = item;
      emit(Il1SipilTodayLoaded(item));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> submitSipilSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    int? draftId,
    String timezone = 'Asia/Jakarta',
  }) async {
    emit(OpgiIl1Loading());
    try {
      final res = await _repository.submitIl1SipilSingle(
        data: data,
        fotoBuktiInspeksi: fotoBuktiInspeksi,
        timezone: timezone,
      );

      if (draftId != null) {
        try {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          _cachedSipilDrafts = _cachedSipilDrafts.where((d) => d['id'] != draftId).toList();
        } catch (_) {}
      }

      final sipilId = int.tryParse(data['sipilId']?.toString() ?? '');
      final resPayload = res ?? <String, dynamic>{...data, 'id': 999999};

      // 1. Optimistic update in-memory sipil list
      if (sipilId != null) {
        _cachedSipilList = _cachedSipilList.map((item) {
          if (item.id == sipilId) {
            return item.copyWith(
              last: resPayload,
              il1Sipil: [resPayload],
              status: resPayload['status']?.toString(),
            );
          }
          return item;
        }).toList();
      }

      // 2. Optimistic update SQLite api_cache
      try {
        if (sipilId != null) {
          await LocalDatabase.instance.optimisticAddIl1Sipil(sipilId, resPayload);
        }
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiIl1Success('Data IL1 Sipil berhasil disimpan'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> updateSipil({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiIl1Loading());
    try {
      final res = await _repository.updateIl1Sipil(id, data);
      final updatePayload = res ?? <String, dynamic>{...data, 'id': id};

      // 1. Optimistic update in-memory today detail
      if (_cachedSipilToday != null && _cachedSipilToday!.id == id) {
        final merged = <String, dynamic>{
          ..._cachedSipilToday!.toJson(),
          ...updatePayload,
        };
        _cachedSipilToday = Il1SipilTodayDetailModel.fromJson(merged);
      }

      // 2. Optimistic update in-memory list
      _cachedSipilList = _cachedSipilList.map((item) {
        final lastId = item.last?['id'];
        if (lastId == id || '$lastId' == '$id') {
          final mergedLast = <String, dynamic>{
            ...item.last!,
            ...updatePayload,
          };
          return item.copyWith(
            last: mergedLast,
            status: mergedLast['status']?.toString(),
          );
        }
        return item;
      }).toList();

      // 3. Optimistic update SQLite api_cache
      try {
        await LocalDatabase.instance.optimisticUpdateIl1Sipil(id, updatePayload);
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiIl1Success('Data IL1 Sipil berhasil diperbarui'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> deleteSipil(int id, {int? sipilId}) async {
    // 1. Optimistic update in-memory state
    _cachedSipilToday = null;
    emit(const Il1SipilTodayLoaded(null));

    _cachedSipilList = _cachedSipilList.map((item) {
      final lastId = item.last?['id'];
      if ((sipilId != null && item.id == sipilId) || (lastId != null && (lastId == id || '$lastId' == '$id'))) {
        return Il1SipilItem(
          id: item.id,
          garduIndukId: item.garduIndukId,
          garduIndukNama: item.garduIndukNama,
          garduInduk: item.garduInduk,
          gedung: item.gedung,
          nama: item.nama,
          isDisabled: item.isDisabled,
          il1Sipil: const [],
          last: null,
          lastData: null,
          status: null,
          drafted: item.drafted,
        );
      }
      return item;
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteIl1Sipil(id);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteIl1Sipil(id);
      emit(const OpgiIl1Success('Data IL1 Sipil berhasil dihapus'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  Future<void> batchSubmitSipil(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');

      try {
        await _repository.submitIl1SipilSingle(
          data: item,
          fotoBuktiInspeksi: item['fotoBuktiInspeksi'],
        );

        if (draftId != null) {
          try {
            await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          } catch (_) {}
        }
        successCount++;
      } catch (e) {
        errorCount++;
        debugPrint('[BATCH SIPIL ERROR] item $i: $e');
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    // Refresh after batch
    await loadSipil(garduIndukId, forceRefresh: true);

    if (errorCount == 0) {
      emit(OpgiIl1Success('Berhasil menyimpan semua ($successCount) draft IL1 Sipil'));
    } else {
      emit(OpgiIl1Success('Selesai: $successCount berhasil, $errorCount gagal'));
    }
  }

  // Legacy method compatibility
  Future<void> submitSipil({
    required Map<String, dynamic> data,
    required XFile file,
    int? draftId,
  }) async {
    emit(OpgiIl1Loading());
    try {
      await _repository.submitIl1Sipil(data: data, file: file);
      if (draftId != null) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
      }
      emit(const OpgiIl1Success('Data IL1 Sipil berhasil disimpan'));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

  // ==========================================
  // DRAFT OPERATIONS
  // ==========================================

  Future<void> saveDraft({
    required String type,
    required String nama,
    required String date,
    required Map<String, dynamic> data,
    int periode = 0,
  }) async {
    await LocalDatabase.instance.insertUnfinishedItemGI({
      'nama': nama,
      'date': date,
      'type': type,
      'periode': periode,
      'data': jsonEncode(data),
    });
  }

  Future<void> deleteDraft(int draftId) async {
    await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
  }

  Future<void> deleteAllDrafts(String type) async {
    await LocalDatabase.instance.deleteUnfinishedItemsByType(type);
  }
}
