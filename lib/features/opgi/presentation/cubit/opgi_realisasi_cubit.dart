import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../../domain/repositories/opgi_repository.dart';

abstract class OpgiRealisasiState extends Equatable {
  const OpgiRealisasiState();
  @override
  List<Object?> get props => [];
}

class OpgiRealisasiInitial extends OpgiRealisasiState {}
class OpgiRealisasiLoading extends OpgiRealisasiState {}

class BebanTrafoLoaded extends OpgiRealisasiState {
  final List<BebanTrafoModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const BebanTrafoLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class BebanTrafoTodayLoaded extends OpgiRealisasiState {
  final List<BebanTrafoTodayItemModel> items;
  const BebanTrafoTodayLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class BebanPenyulangLoaded extends OpgiRealisasiState {
  final List<BebanPenyulangModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const BebanPenyulangLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class BebanPenyulangTodayLoaded extends OpgiRealisasiState {
  final List<BebanPenyulangTodayItemModel> items;
  const BebanPenyulangTodayLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class TeganganTrafoLoaded extends OpgiRealisasiState {
  final List<TeganganTrafoModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const TeganganTrafoLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class TeganganTrafoTodayLoaded extends OpgiRealisasiState {
  final List<TeganganTrafoTodayItemModel> items;
  const TeganganTrafoTodayLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class KwhHarianLoaded extends OpgiRealisasiState {
  final List<KwhHarianModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const KwhHarianLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class KwhHarianTodayLoaded extends OpgiRealisasiState {
  final List<KwhHarianTodayItemModel> items;
  const KwhHarianTodayLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class OpgiBatchProgress extends OpgiRealisasiState {
  final int completed;
  final int total;
  const OpgiBatchProgress({required this.completed, required this.total});
  @override
  List<Object?> get props => [completed, total];
}

class OpgiRealisasiSuccess extends OpgiRealisasiState {
  final String message;
  const OpgiRealisasiSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class OpgiRealisasiError extends OpgiRealisasiState {
  final String message;
  const OpgiRealisasiError(this.message);
  @override
  List<Object?> get props => [message];
}

class OpgiRealisasiCubit extends Cubit<OpgiRealisasiState> {
  final OpgiRepository _repository;

  // Beban Penyulang in-memory caches
  List<BebanPenyulangModel> _cachedPenyulangList = [];
  List<Map<String, dynamic>> _cachedPenyulangDrafts = [];
  List<BebanPenyulangTodayItemModel> _cachedTodayList = [];

  List<BebanPenyulangModel> get cachedPenyulangList => _cachedPenyulangList;
  List<Map<String, dynamic>> get cachedPenyulangDrafts => _cachedPenyulangDrafts;
  List<BebanPenyulangTodayItemModel> get cachedTodayList => _cachedTodayList;
  List<BebanPenyulangTodayItemModel> get cachedBebanPenyulangTodayList => _cachedTodayList;

  // Beban Trafo in-memory caches
  List<BebanTrafoModel> _cachedBebanTrafoList = [];
  List<Map<String, dynamic>> _cachedBebanTrafoDrafts = [];
  List<BebanTrafoTodayItemModel> _cachedBebanTrafoTodayList = [];

  List<BebanTrafoModel> get cachedBebanTrafoList => _cachedBebanTrafoList;
  List<Map<String, dynamic>> get cachedBebanTrafoDrafts => _cachedBebanTrafoDrafts;
  List<BebanTrafoTodayItemModel> get cachedBebanTrafoTodayList => _cachedBebanTrafoTodayList;

  // Tegangan Trafo in-memory caches
  List<TeganganTrafoModel> _cachedTeganganTrafoList = [];
  List<Map<String, dynamic>> _cachedTeganganTrafoDrafts = [];
  List<TeganganTrafoTodayItemModel> _cachedTeganganTrafoTodayList = [];

  List<TeganganTrafoModel> get cachedTeganganTrafoList => _cachedTeganganTrafoList;
  List<Map<String, dynamic>> get cachedTeganganTrafoDrafts => _cachedTeganganTrafoDrafts;
  List<TeganganTrafoTodayItemModel> get cachedTeganganTrafoTodayList => _cachedTeganganTrafoTodayList;

  // Kwh Harian in-memory caches
  List<KwhHarianModel> _cachedKwhHarianList = [];
  List<Map<String, dynamic>> _cachedKwhHarianDrafts = [];
  List<KwhHarianTodayItemModel> _cachedKwhHarianTodayList = [];

  List<KwhHarianModel> get cachedKwhHarianList => _cachedKwhHarianList;
  List<Map<String, dynamic>> get cachedKwhHarianDrafts => _cachedKwhHarianDrafts;
  List<KwhHarianTodayItemModel> get cachedKwhHarianTodayList => _cachedKwhHarianTodayList;

  OpgiRealisasiCubit(this._repository) : super(OpgiRealisasiInitial());

  // ==========================================
  // 1. BEBAN TRAFO
  // ==========================================
  Future<void> loadBebanTrafo(
    int garduIndukId, [
    String? date,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  ]) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getBebanTrafoList(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedBebanTrafoList = items;
      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
          type: 'beban-trafo',
        );
      } catch (_) {}
      _cachedBebanTrafoDrafts = drafts;
      emit(BebanTrafoLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitBebanTrafoSingle({
    required dynamic file,
    required Map<String, dynamic> data,
    int? draftId,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.submitBebanTrafoSingle(file: file, data: data);
      if (draftId != null) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
      }
      if (res != null) {
        final trafoId = data['trafoId'] is int
            ? data['trafoId'] as int
            : int.tryParse('${data['trafoId']}') ?? 0;

        // 1. Optimistic update SQLite api_cache
        await LocalDatabase.instance.optimisticAddBebanTrafo(trafoId, res);

        // 2. Optimistic update in-memory trafo list
        final newBebanItem = TrafoBebanItemModel.fromJson(res);
        _cachedBebanTrafoList = _cachedBebanTrafoList.map((t) {
          if (t.id == trafoId) {
            final exists = t.beban.any((b) =>
                b.id == newBebanItem.id ||
                (b.periode == newBebanItem.periode && b.tanggal == newBebanItem.tanggal));
            if (!exists) {
              final newBeban = List<TrafoBebanItemModel>.from(t.beban)..add(newBebanItem);
              return t.copyWith(beban: newBeban);
            }
          }
          return t;
        }).toList();

        // 3. Optimistic update in-memory today list
        final newTodayItem = BebanTrafoTodayItemModel.fromJson(res);
        final existsToday = _cachedBebanTrafoTodayList.any((b) =>
            b.id == newTodayItem.id ||
            (b.periode == newTodayItem.periode && b.tanggal == newTodayItem.tanggal));
        if (!existsToday) {
          _cachedBebanTrafoTodayList = (List<BebanTrafoTodayItemModel>.from(_cachedBebanTrafoTodayList)..add(newTodayItem))
            ..sort((a, b) => a.periode.compareTo(b.periode));
        }
      }
      emit(const OpgiRealisasiSuccess('Data Beban Trafo berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> batchSubmitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');
      final fotoUri = item['file']?.toString();
      final data = item['data'] as Map<String, dynamic>? ?? {};

      try {
        final trafoId = data['trafoId'] is int
            ? data['trafoId'] as int
            : int.tryParse('${data['trafoId']}');

        final res = await _repository.submitBebanTrafoSingle(
          file: fotoUri ?? '',
          data: data,
        );

        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
        }

        if (res != null && trafoId != null) {
          await LocalDatabase.instance.optimisticAddBebanTrafo(trafoId, res);
          final newBebanItem = TrafoBebanItemModel.fromJson(res);
          _cachedBebanTrafoList = _cachedBebanTrafoList.map((t) {
            if (t.id == trafoId) {
              final exists = t.beban.any((b) =>
                  b.id == newBebanItem.id ||
                  (b.periode == newBebanItem.periode && b.tanggal == newBebanItem.tanggal));
              if (!exists) {
                final newBeban = List<TrafoBebanItemModel>.from(t.beban)..add(newBebanItem);
                return t.copyWith(beban: newBeban);
              }
            }
            return t;
          }).toList();
        }
        successCount++;
      } catch (e) {
        debugPrint('[BATCH SUBMIT BEBAN TRAFO ITEM $i ERROR] $e');
        errorCount++;
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    if (successCount > 0) {
      final msg = errorCount > 0
          ? '$successCount data berhasil dan $errorCount gagal disimpan'
          : '$successCount data berhasil disimpan';
      emit(OpgiRealisasiSuccess(msg));
    } else {
      emit(OpgiRealisasiError('$errorCount item gagal disimpan'));
    }

    List<Map<String, dynamic>> remainingDrafts = [];
    try {
      remainingDrafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'beban-trafo',
      );
    } catch (_) {}
    _cachedBebanTrafoDrafts = remainingDrafts;
    emit(BebanTrafoLoaded(items: _cachedBebanTrafoList, localDrafts: remainingDrafts));
  }

  Future<void> deleteAllBebanTrafoDrafts(int garduIndukId, List<int> draftIds) async {
    emit(OpgiRealisasiLoading());
    try {
      for (final id in draftIds) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(id);
      }
      emit(const OpgiRealisasiSuccess('Semua draft berhasil dihapus'));
      await loadBebanTrafo(garduIndukId);
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> loadBebanTrafoToday(
    int trafoId,
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getBebanTrafoToday(
        trafoId,
        garduIndukId: garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedBebanTrafoTodayList = items;
      emit(BebanTrafoTodayLoaded(items));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> updateBebanTrafoMobile({
    required int bebanId,
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.updateBebanTrafoMobile(
        bebanId,
        file: file,
        data: data,
      );
      final updatePayload = res ?? <String, dynamic>{
        ...data,
        'id': bebanId,
      };

      // 1. Optimistic update in-memory today list
      final idx = _cachedBebanTrafoTodayList.indexWhere((item) => item.id == bebanId);
      final existingTodayItem = (idx != -1) ? _cachedBebanTrafoTodayList[idx] : null;
      final mergedToday = <String, dynamic>{
        if (existingTodayItem != null) ...existingTodayItem.toJson(),
        ...updatePayload,
      };
      final updatedTodayItem = BebanTrafoTodayItemModel.fromJson(mergedToday);
      if (idx != -1) {
        _cachedBebanTrafoTodayList = List.from(_cachedBebanTrafoTodayList)..[idx] = updatedTodayItem;
      }

      // 2. Optimistic update in-memory trafo list
      _cachedBebanTrafoList = _cachedBebanTrafoList.map((t) {
        final bIdx = t.beban.indexWhere((b) => b.id == bebanId);
        if (bIdx != -1) {
          final existingBeban = t.beban[bIdx];
          final mergedBeban = <String, dynamic>{
            ...existingBeban.toJson(),
            ...updatePayload,
          };
          final updatedBebanItem = TrafoBebanItemModel.fromJson(mergedBeban);
          final newBeban = List<TrafoBebanItemModel>.from(t.beban)..[bIdx] = updatedBebanItem;
          return t.copyWith(beban: newBeban);
        }
        return t;
      }).toList();

      // 3. Optimistic update SQLite api_cache
      try {
        await LocalDatabase.instance.optimisticUpdateBebanTrafo(bebanId, updatePayload);
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiRealisasiSuccess('Data Beban Trafo berhasil diperbarui'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> deleteBebanTrafo(int bebanId) async {
    // 1. Optimistic update in-memory state
    _cachedBebanTrafoTodayList = _cachedBebanTrafoTodayList.where((item) => item.id != bebanId).toList();
    emit(BebanTrafoTodayLoaded(List.from(_cachedBebanTrafoTodayList)));

    _cachedBebanTrafoList = _cachedBebanTrafoList.map((t) {
      final newBeban = t.beban.where((b) => b.id != bebanId).toList();
      return t.copyWith(beban: newBeban);
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteBebanTrafo(bebanId);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteBebanTrafo(bebanId);
      emit(const OpgiRealisasiSuccess('Data Beban Trafo berhasil dihapus'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // ==========================================
  // 2. BEBAN PENYULANG
  // ==========================================
  Future<void> loadBebanPenyulang(
    int garduIndukId, [
    String? date,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  ]) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getPenyulangList(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedPenyulangList = items;
      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
          type: 'beban-penyulang',
        );
      } catch (_) {}
      _cachedPenyulangDrafts = drafts;
      emit(BebanPenyulangLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitBebanPenyulangSingle({
    required dynamic file,
    required Map<String, dynamic> data,
    int? draftId,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.submitBebanPenyulangSingle(file: file, data: data);
      if (draftId != null) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
      }
      if (res != null) {
        final penyulangId = data['penyulangId'] is int
            ? data['penyulangId'] as int
            : int.tryParse('${data['penyulangId']}') ?? 0;

        // 1. Optimistic update SQLite api_cache
        await LocalDatabase.instance.optimisticAddBebanPenyulang(penyulangId, res);

        // 2. Optimistic update in-memory penyulang list
        final newBebanItem = PenyulangBebanItemModel.fromJson(res);
        _cachedPenyulangList = _cachedPenyulangList.map((p) {
          if (p.id == penyulangId) {
            final exists = p.beban.any((b) =>
                b.id == newBebanItem.id ||
                (b.periode == newBebanItem.periode && b.tanggal == newBebanItem.tanggal));
            if (!exists) {
              final newBeban = List<PenyulangBebanItemModel>.from(p.beban)..add(newBebanItem);
              return p.copyWith(beban: newBeban);
            }
          }
          return p;
        }).toList();

        // 3. Optimistic update in-memory today list
        final newTodayItem = BebanPenyulangTodayItemModel.fromJson(res);
        final existsToday = _cachedTodayList.any((b) =>
            b.id == newTodayItem.id ||
            (b.periode == newTodayItem.periode && b.tanggal == newTodayItem.tanggal));
        if (!existsToday) {
          _cachedTodayList = (List<BebanPenyulangTodayItemModel>.from(_cachedTodayList)..add(newTodayItem))
            ..sort((a, b) => a.periode.compareTo(b.periode));
        }
      }
      emit(const OpgiRealisasiSuccess('Data Beban Penyulang berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> batchSubmitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');
      final foto = item['foto'];
      final fotoUri = foto is Map ? foto['uri'] as String? : (foto is String ? foto : null);

      try {
        final penyulangId = item['penyulangId'] is int
            ? item['penyulangId'] as int
            : int.tryParse('${item['penyulangId']}') ??
                (item['id'] is int ? item['id'] as int : int.tryParse('${item['id']}'));

        final beban = (item['beban'] is num)
            ? (item['beban'] as num).round()
            : (num.tryParse('${item['beban']}') ?? 0).round();

        final durasi = (item['durasi'] is num)
            ? (item['durasi'] as num).toDouble()
            : (num.tryParse('${item['durasi']}')?.toDouble() ?? 0.0);

        final periode = item['periode'] is int
            ? item['periode'] as int
            : int.tryParse('${item['periode']}') ?? 0;
        final tanggal = item['tanggal'] is int
            ? item['tanggal'] as int
            : int.tryParse('${item['tanggal']}') ?? DateTime.now().day;
        final bulan = item['bulan'] is int
            ? item['bulan'] as int
            : int.tryParse('${item['bulan']}') ?? DateTime.now().month;
        final tahun = item['tahun'] is int
            ? item['tahun'] as int
            : int.tryParse('${item['tahun']}') ?? DateTime.now().year;

        final cleanPayload = <String, dynamic>{
          'penyulangId': penyulangId,
          'beban': beban,
          'periode': periode,
          'tanggal': tanggal,
          'bulan': bulan,
          'tahun': tahun,
          'durasi': durasi,
          'timezone': 'Asia/Jakarta',
          if (garduIndukId > 0) 'garduIndukId': garduIndukId,
        };

        final res = await _repository.submitBebanPenyulangSingle(
          file: fotoUri ?? '',
          data: cleanPayload,
        );

        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
        }
        if (res != null && penyulangId != null) {
          await LocalDatabase.instance.optimisticAddBebanPenyulang(penyulangId, res);
          final newBebanItem = PenyulangBebanItemModel.fromJson(res);
          _cachedPenyulangList = _cachedPenyulangList.map((p) {
            if (p.id == penyulangId) {
              final exists = p.beban.any((b) =>
                  b.id == newBebanItem.id ||
                  (b.periode == newBebanItem.periode && b.tanggal == newBebanItem.tanggal));
              if (!exists) {
                final newBeban = List<PenyulangBebanItemModel>.from(p.beban)..add(newBebanItem);
                return p.copyWith(beban: newBeban);
              }
            }
            return p;
          }).toList();
        }
        successCount++;
      } catch (e) {
        debugPrint('[BATCH SUBMIT ITEM $i ERROR] $e');
        errorCount++;
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    if (successCount > 0) {
      final msg = errorCount > 0
          ? '$successCount data berhasil dan $errorCount gagal disimpan'
          : '$successCount data berhasil disimpan';
      emit(OpgiRealisasiSuccess(msg));
    } else {
      emit(OpgiRealisasiError('$errorCount item gagal disimpan'));
    }

    List<Map<String, dynamic>> remainingDrafts = [];
    try {
      remainingDrafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'beban-penyulang',
      );
    } catch (_) {}
    _cachedPenyulangDrafts = remainingDrafts;
    emit(BebanPenyulangLoaded(items: _cachedPenyulangList, localDrafts: remainingDrafts));
  }

  Future<void> deleteAllDrafts(int garduIndukId, List<int> draftIds) async {
    emit(OpgiRealisasiLoading());
    try {
      for (final id in draftIds) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(id);
      }
      emit(const OpgiRealisasiSuccess('Semua draft berhasil dihapus'));
      await loadBebanPenyulang(garduIndukId);
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> loadBebanPenyulangToday(
    int penyulangId,
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getBebanPenyulangToday(
        penyulangId,
        garduIndukId: garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedTodayList = items;
      emit(BebanPenyulangTodayLoaded(items));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> updateBebanPenyulangMobile({
    required int bebanId,
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.updateBebanPenyulangMobile(bebanId, file: file, data: data);
      if (res != null) {
        // 1. Optimistic update SQLite api_cache
        await LocalDatabase.instance.optimisticUpdateBebanPenyulang(bebanId, res);

        // 2. Optimistic update in-memory today list
        final updatedTodayItem = BebanPenyulangTodayItemModel.fromJson(res);
        final idx = _cachedTodayList.indexWhere((item) => item.id == bebanId);
        if (idx != -1) {
          _cachedTodayList = List.from(_cachedTodayList)..[idx] = updatedTodayItem;
        }

        // 3. Optimistic update in-memory penyulang list
        final updatedBebanItem = PenyulangBebanItemModel.fromJson(res);
        _cachedPenyulangList = _cachedPenyulangList.map((p) {
          final bIdx = p.beban.indexWhere((b) => b.id == bebanId);
          if (bIdx != -1) {
            final newBeban = List<PenyulangBebanItemModel>.from(p.beban)..[bIdx] = updatedBebanItem;
            return p.copyWith(beban: newBeban);
          }
          return p;
        }).toList();
      }
      emit(const OpgiRealisasiSuccess('Data Beban Penyulang berhasil diperbarui'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> deleteBebanPenyulang(int bebanId) async {
    // 1. Optimistic update in-memory state
    _cachedTodayList = _cachedTodayList.where((item) => item.id != bebanId).toList();
    emit(BebanPenyulangTodayLoaded(List.from(_cachedTodayList)));

    _cachedPenyulangList = _cachedPenyulangList.map((p) {
      final newBeban = p.beban.where((b) => b.id != bebanId).toList();
      return p.copyWith(beban: newBeban);
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteBebanPenyulang(bebanId);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteBebanPenyulang(bebanId);
      emit(const OpgiRealisasiSuccess('Data Beban Penyulang berhasil dihapus'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) async {
    await updateUrutanPenyulangCustom(items);
  }

  Future<void> updateUrutanPenyulangCustom(List<Map<String, dynamic>> items) async {
    emit(OpgiRealisasiLoading());
    try {
      await _repository.updateUrutanPenyulangCustom(items);
      emit(const OpgiRealisasiSuccess('Urutan Penyulang berhasil diperbarui'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // ==========================================
  // 3. TEGANGAN TRAFO
  // ==========================================
  Future<void> loadTeganganTrafo(
    int garduIndukId, [
    String? date,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  ]) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getTeganganTrafoList(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedTeganganTrafoList = items;
      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
          type: 'tegangan-trafo',
        );
      } catch (_) {}
      _cachedTeganganTrafoDrafts = drafts;
      emit(TeganganTrafoLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitTeganganTrafoSingle({
    required dynamic fotoMV,
    required dynamic fotoHV,
    required Map<String, dynamic> data,
    int? draftId,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.submitTeganganTrafoSingle(
        fileMV: fotoMV,
        fileHV: fotoHV,
        data: data,
      );
      if (draftId != null) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
      }
      if (res != null) {
        final trafoId = data['trafoId'] is int
            ? data['trafoId'] as int
            : int.tryParse('${data['trafoId']}') ?? 0;

        // 1. Optimistic update SQLite api_cache
        await LocalDatabase.instance.optimisticAddTeganganTrafo(trafoId, res);

        // 2. Optimistic update in-memory tegangan list
        final newTeganganItem = TrafoTeganganItemModel.fromJson(res);
        _cachedTeganganTrafoList = _cachedTeganganTrafoList.map((t) {
          if (t.id == trafoId) {
            final exists = t.tegangan.any((b) =>
                b.id == newTeganganItem.id ||
                (b.periode == newTeganganItem.periode && b.tanggal == newTeganganItem.tanggal));
            if (!exists) {
              final newTegangan = List<TrafoTeganganItemModel>.from(t.tegangan)..add(newTeganganItem);
              return t.copyWith(tegangan: newTegangan);
            }
          }
          return t;
        }).toList();

        // 3. Optimistic update in-memory today list
        final newTodayItem = TeganganTrafoTodayItemModel.fromJson(res);
        final existsToday = _cachedTeganganTrafoTodayList.any((b) =>
            b.id == newTodayItem.id ||
            (b.periode == newTodayItem.periode && b.tanggal == newTodayItem.tanggal));
        if (!existsToday) {
          _cachedTeganganTrafoTodayList = (List<TeganganTrafoTodayItemModel>.from(_cachedTeganganTrafoTodayList)..add(newTodayItem))
            ..sort((a, b) => a.periode.compareTo(b.periode));
        }
      }
      emit(const OpgiRealisasiSuccess('Data Tegangan Trafo berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> batchSubmitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');
      final fotoMV = item['fotoMV'];
      final fotoHV = item['fotoHV'];
      final data = item['data'] as Map<String, dynamic>? ?? {};

      try {
        final trafoId = data['trafoId'] is int
            ? data['trafoId'] as int
            : int.tryParse('${data['trafoId']}');

        final res = await _repository.submitTeganganTrafoSingle(
          fileMV: fotoMV ?? '',
          fileHV: fotoHV ?? '',
          data: data,
        );

        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
        }

        if (res != null && trafoId != null) {
          await LocalDatabase.instance.optimisticAddTeganganTrafo(trafoId, res);
          final newTeganganItem = TrafoTeganganItemModel.fromJson(res);
          _cachedTeganganTrafoList = _cachedTeganganTrafoList.map((t) {
            if (t.id == trafoId) {
              final exists = t.tegangan.any((b) =>
                  b.id == newTeganganItem.id ||
                  (b.periode == newTeganganItem.periode && b.tanggal == newTeganganItem.tanggal));
              if (!exists) {
                final newTegangan = List<TrafoTeganganItemModel>.from(t.tegangan)..add(newTeganganItem);
                return t.copyWith(tegangan: newTegangan);
              }
            }
            return t;
          }).toList();
        }
        successCount++;
      } catch (e) {
        debugPrint('[BATCH SUBMIT TEGANGAN TRAFO ITEM $i ERROR] $e');
        errorCount++;
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    if (successCount > 0) {
      final msg = errorCount > 0
          ? '$successCount data berhasil dan $errorCount gagal disimpan'
          : '$successCount data berhasil disimpan';
      emit(OpgiRealisasiSuccess(msg));
    } else {
      emit(OpgiRealisasiError('$errorCount item gagal disimpan'));
    }

    List<Map<String, dynamic>> remainingDrafts = [];
    try {
      remainingDrafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'tegangan-trafo',
      );
    } catch (_) {}
    _cachedTeganganTrafoDrafts = remainingDrafts;
    emit(TeganganTrafoLoaded(items: _cachedTeganganTrafoList, localDrafts: remainingDrafts));
  }

  Future<void> deleteAllTeganganTrafoDrafts(int garduIndukId, List<int> draftIds) async {
    emit(OpgiRealisasiLoading());
    try {
      for (final id in draftIds) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(id);
      }
      emit(const OpgiRealisasiSuccess('Semua draft berhasil dihapus'));
      await loadTeganganTrafo(garduIndukId);
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> loadTeganganTrafoToday(
    int trafoId,
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getTeganganTrafoToday(
        trafoId,
        garduIndukId: garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedTeganganTrafoTodayList = items;
      emit(TeganganTrafoTodayLoaded(items));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> updateTeganganTrafoMobile({
    required int teganganId,
    dynamic fotoMV,
    dynamic fotoHV,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.updateTeganganTrafoMobile(
        teganganId,
        fileMV: fotoMV,
        fileHV: fotoHV,
        data: data,
      );
      final updatePayload = res ?? <String, dynamic>{
        ...data,
        'id': teganganId,
      };

      // 1. Optimistic update in-memory today list
      final idx = _cachedTeganganTrafoTodayList.indexWhere((item) => item.id == teganganId);
      final existingTodayItem = (idx != -1) ? _cachedTeganganTrafoTodayList[idx] : null;
      final mergedToday = <String, dynamic>{
        if (existingTodayItem != null) ...existingTodayItem.toJson(),
        ...updatePayload,
      };
      final updatedTodayItem = TeganganTrafoTodayItemModel.fromJson(mergedToday);
      if (idx != -1) {
        _cachedTeganganTrafoTodayList = List.from(_cachedTeganganTrafoTodayList)..[idx] = updatedTodayItem;
      }

      // 2. Optimistic update in-memory tegangan list
      _cachedTeganganTrafoList = _cachedTeganganTrafoList.map((t) {
        final bIdx = t.tegangan.indexWhere((b) => b.id == teganganId);
        if (bIdx != -1) {
          final existingTegangan = t.tegangan[bIdx];
          final mergedTegangan = <String, dynamic>{
            ...existingTegangan.toJson(),
            ...updatePayload,
          };
          final updatedTeganganItem = TrafoTeganganItemModel.fromJson(mergedTegangan);
          final newTegangan = List<TrafoTeganganItemModel>.from(t.tegangan)..[bIdx] = updatedTeganganItem;
          return t.copyWith(tegangan: newTegangan);
        }
        return t;
      }).toList();

      // 3. Optimistic update SQLite api_cache
      try {
        await LocalDatabase.instance.optimisticUpdateTeganganTrafo(teganganId, updatePayload);
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiRealisasiSuccess('Data Tegangan Trafo berhasil diperbarui'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> deleteTeganganTrafo(int teganganId) async {
    // 1. Optimistic update in-memory state
    _cachedTeganganTrafoTodayList = _cachedTeganganTrafoTodayList.where((item) => item.id != teganganId).toList();
    emit(TeganganTrafoTodayLoaded(List.from(_cachedTeganganTrafoTodayList)));

    _cachedTeganganTrafoList = _cachedTeganganTrafoList.map((t) {
      final newTegangan = t.tegangan.where((b) => b.id != teganganId).toList();
      return t.copyWith(tegangan: newTegangan);
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteTeganganTrafo(teganganId);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteTeganganTrafo(teganganId);
      emit(const OpgiRealisasiSuccess('Data Tegangan Trafo berhasil dihapus'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // ==========================================
  // 4. KWH HARIAN
  // ==========================================
  Future<void> loadKwhHarian(
    int garduIndukId, [
    String? date,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  ]) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getKwhHarianList(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedKwhHarianList = items;
      List<Map<String, dynamic>> drafts = [];
      try {
        drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
          type: 'kwh-harian',
        );
      } catch (_) {}
      _cachedKwhHarianDrafts = drafts;
      emit(KwhHarianLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitKwhHarianSingle({
    required List<Map<String, dynamic>> filesWithJenis,
    required Map<String, dynamic> data,
    int? draftId,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.submitKwhHarianSingle(
        filesWithJenis: filesWithJenis,
        data: data,
      );

      final objectId = data['objectId'] is int
          ? data['objectId'] as int
          : int.tryParse('${data['objectId']}') ?? 0;
      final type = data['type']?.toString() ?? 'PENYULANG';
      final kelompok = data['kelompok']?.toString() ?? 'FEEDER';

      // Hapus draft terkait jika ada (baik via draftId maupun matching objectId & kelompok)
      if (draftId != null) {
        try {
          await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
        } catch (_) {}
      }
      try {
        final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'kwh-harian');
        for (final d in drafts) {
          final dData = d['data'] is Map ? d['data'] as Map : {};
          final dObjId = int.tryParse('${dData['objectId']}');
          final dKel = dData['kelompok']?.toString();
          if (dObjId == objectId && (dKel == null || dKel == kelompok)) {
            final dId = d['id'] is int ? d['id'] as int : int.tryParse('${d['id']}');
            if (dId != null) {
              await LocalDatabase.instance.deleteUnfinishedItemGI(dId);
            }
          }
        }
      } catch (_) {}

      // Refresh remaining drafts in-memory
      try {
        _cachedKwhHarianDrafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'kwh-harian');
      } catch (_) {}

      final List<Map<String, dynamic>> itemsToAdd = (res != null && res['data'] is List)
          ? (res['data'] as List).cast<Map<String, dynamic>>()
          : (res != null ? [res] : []);

      // 1. Optimistic update in-memory list
      _cachedKwhHarianList = _cachedKwhHarianList.map((k) {
        if (k.id == objectId && k.type == type && k.kelompok == kelompok) {
          final entries = itemsToAdd.map((json) => KwhHarianEntryModel.fromJson(json)).toList();
          return k.copyWith(isDone: true, kwhHarian: entries);
        }
        return k;
      }).toList();

      if (itemsToAdd.isNotEmpty) {
        final todayEntries = itemsToAdd.map((json) => KwhHarianTodayItemModel.fromJson(json)).toList();
        _cachedKwhHarianTodayList = todayEntries;
      }

      // 2. Optimistic update SQLite api_cache
      if (itemsToAdd.isNotEmpty) {
        try {
          await LocalDatabase.instance.optimisticAddKwhHarian(objectId, itemsToAdd);
        } catch (e) {
          debugPrint('[DB ERROR] $e');
        }
      }

      emit(const OpgiRealisasiSuccess('Data KWH Harian berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> batchSubmitKwhHarian(int garduIndukId, List<Map<String, dynamic>> parsedDrafts) async {
    if (parsedDrafts.isEmpty) return;
    emit(OpgiBatchProgress(completed: 0, total: parsedDrafts.length));

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < parsedDrafts.length; i++) {
      final item = parsedDrafts[i];
      final draftId = item['draftId'] is int ? item['draftId'] as int : int.tryParse('${item['draftId']}');
      final filesWithJenis = (item['filesWithJenis'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final data = item['data'] as Map<String, dynamic>? ?? {};

      try {
        final objectId = data['objectId'] is int
            ? data['objectId'] as int
            : int.tryParse('${data['objectId']}');
        final type = data['type']?.toString() ?? 'PENYULANG';
        final kelompok = data['kelompok']?.toString() ?? 'FEEDER';

        final res = await _repository.submitKwhHarianSingle(
          filesWithJenis: filesWithJenis,
          data: data,
        );

        if (draftId != null) {
          try {
            await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
          } catch (_) {}
        }
        if (objectId != null) {
          try {
            final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'kwh-harian');
            for (final d in drafts) {
              final dData = d['data'] is Map ? d['data'] as Map : {};
              final dObjId = int.tryParse('${dData['objectId']}');
              final dKel = dData['kelompok']?.toString();
              if (dObjId == objectId && (dKel == null || dKel == kelompok)) {
                final dId = d['id'] is int ? d['id'] as int : int.tryParse('${d['id']}');
                if (dId != null) {
                  await LocalDatabase.instance.deleteUnfinishedItemGI(dId);
                }
              }
            }
          } catch (_) {}
        }

        if (objectId != null) {
          final List<Map<String, dynamic>> itemsToAdd = (res != null && res['data'] is List)
              ? (res['data'] as List).cast<Map<String, dynamic>>()
              : (res != null ? [res] : []);

          _cachedKwhHarianList = _cachedKwhHarianList.map((k) {
            if (k.id == objectId && k.type == type && k.kelompok == kelompok) {
              final entries = itemsToAdd.map((json) => KwhHarianEntryModel.fromJson(json)).toList();
              return k.copyWith(isDone: true, kwhHarian: entries);
            }
            return k;
          }).toList();

          if (itemsToAdd.isNotEmpty) {
            try {
              await LocalDatabase.instance.optimisticAddKwhHarian(objectId, itemsToAdd);
            } catch (e) {
              debugPrint('[DB ERROR] $e');
            }
          }
        }
        successCount++;
      } catch (e) {
        debugPrint('[BATCH SUBMIT KWH HARIAN ITEM $i ERROR] $e');
        errorCount++;
      }

      emit(OpgiBatchProgress(completed: i + 1, total: parsedDrafts.length));
    }

    if (successCount > 0) {
      final msg = errorCount > 0
          ? '$successCount data berhasil dan $errorCount gagal disimpan'
          : '$successCount data berhasil disimpan';
      emit(OpgiRealisasiSuccess(msg));
    } else {
      emit(OpgiRealisasiError('$errorCount item gagal disimpan'));
    }

    List<Map<String, dynamic>> remainingDrafts = [];
    try {
      remainingDrafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'kwh-harian',
      );
    } catch (_) {}
    _cachedKwhHarianDrafts = remainingDrafts;
    emit(KwhHarianLoaded(items: _cachedKwhHarianList, localDrafts: remainingDrafts));
  }

  Future<void> deleteAllKwhHarianDrafts(int garduIndukId, List<int> draftIds) async {
    emit(OpgiRealisasiLoading());
    try {
      for (final id in draftIds) {
        await LocalDatabase.instance.deleteUnfinishedItemGI(id);
      }
      emit(const OpgiRealisasiSuccess('Semua draft berhasil dihapus'));
      await loadKwhHarian(garduIndukId);
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> loadKwhHarianToday(
    int objectId, {
    required String type,
    required String kelompok,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getKwhHarianToday(
        objectId,
        type: type,
        kelompok: kelompok,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      _cachedKwhHarianTodayList = items;
      emit(KwhHarianTodayLoaded(items));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> updateKwhHarianMobile({
    required int id,
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiRealisasiLoading());
    try {
      final res = await _repository.updateKwhHarianMobile(id, file: file, data: data);
      final updatePayload = res ?? <String, dynamic>{
        ...data,
        'id': id,
      };

      // 1. Optimistic update in-memory today list
      final idx = _cachedKwhHarianTodayList.indexWhere((item) => item.id == id);
      final existingTodayItem = (idx != -1) ? _cachedKwhHarianTodayList[idx] : null;
      final mergedToday = <String, dynamic>{
        if (existingTodayItem != null) ...existingTodayItem.toJson(),
        ...updatePayload,
      };
      final updatedTodayItem = KwhHarianTodayItemModel.fromJson(mergedToday);
      if (idx != -1) {
        _cachedKwhHarianTodayList = List.from(_cachedKwhHarianTodayList)..[idx] = updatedTodayItem;
      }

      // 2. Optimistic update SQLite api_cache
      try {
        await LocalDatabase.instance.optimisticUpdateKwhHarian(id, updatePayload);
      } catch (e) {
        debugPrint('[DB ERROR] $e');
      }

      emit(const OpgiRealisasiSuccess('Data KWH Harian berhasil diperbarui'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> deleteKwhHarianToday({
    required List<int> ids,
    required int objectId,
    required String type,
    required String kelompok,
  }) async {
    // 1. Optimistic update in-memory state
    _cachedKwhHarianTodayList = [];
    emit(const KwhHarianTodayLoaded([]));

    _cachedKwhHarianList = _cachedKwhHarianList.map((k) {
      if (k.id == objectId && k.type == type && k.kelompok == kelompok) {
        return k.copyWith(isDone: false);
      }
      return k;
    }).toList();

    // 2. Optimistic update SQLite api_cache
    try {
      await LocalDatabase.instance.optimisticDeleteKwhHarian(ids);
    } catch (e) {
      debugPrint('[DB ERROR] $e');
    }

    // 3. Server call
    try {
      await _repository.deleteKwhHarianToday(ids);
      emit(const OpgiRealisasiSuccess('Data KWH Harian berhasil dihapus'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // ==========================================
  // SHARED OFFLINE DRAFT HELPERS
  // ==========================================
  Future<void> saveDraft({
    required String type,
    required String nama,
    required String date,
    int? periode,
    required Map<String, dynamic> data,
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
}
