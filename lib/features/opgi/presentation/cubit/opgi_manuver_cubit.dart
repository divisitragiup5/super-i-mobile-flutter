import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/opgi_manuver_model.dart';
import '../../domain/repositories/opgi_repository.dart';

abstract class OpgiManuverState extends Equatable {
  const OpgiManuverState();
  @override
  List<Object?> get props => [];
}

class OpgiManuverInitial extends OpgiManuverState {}

class OpgiManuverLoading extends OpgiManuverState {}

class OpgiManuverLoaded extends OpgiManuverState {
  final List<ManuverItemModel> items;
  final List<Map<String, dynamic>> drafts;

  const OpgiManuverLoaded(this.items, {this.drafts = const []});

  @override
  List<Object?> get props => [items, drafts];
}

class OpgiManuverProgressLoaded extends OpgiManuverState {
  final List<ManuverProgressModel> items;
  final List<Map<String, dynamic>> drafts;

  const OpgiManuverProgressLoaded(this.items, {this.drafts = const []});

  @override
  List<Object?> get props => [items, drafts];
}

class OpgiManuverPenyulangLoaded extends OpgiManuverState {
  final List<Map<String, dynamic>> penyulangList;

  const OpgiManuverPenyulangLoaded(this.penyulangList);

  @override
  List<Object?> get props => [penyulangList];
}

class OpgiManuverSuccess extends OpgiManuverState {
  final String message;
  final String? status; // 'OPEN' | 'CLOSE' etc.
  final List<ManuverItemModel>? items;
  final List<ManuverProgressModel>? progressItems;
  final List<Map<String, dynamic>>? drafts;

  const OpgiManuverSuccess(
    this.message, {
    this.status,
    this.items,
    this.progressItems,
    this.drafts,
  });

  @override
  List<Object?> get props => [message, status, items, progressItems, drafts];
}

class OpgiManuverError extends OpgiManuverState {
  final String message;
  final List<ManuverItemModel>? items;
  final List<ManuverProgressModel>? progressItems;
  final List<Map<String, dynamic>>? drafts;

  const OpgiManuverError(
    this.message, {
    this.items,
    this.progressItems,
    this.drafts,
  });

  @override
  List<Object?> get props => [message, items, progressItems, drafts];
}

class OpgiManuverCubit extends Cubit<OpgiManuverState> {
  final OpgiRepository _repository;
  List<ManuverItemModel> _cachedItems = [];
  List<ManuverProgressModel> _cachedProgressItems = [];
  List<Map<String, dynamic>> _cachedDrafts = [];
  List<Map<String, dynamic>> _cachedProgressDrafts = [];

  List<ManuverItemModel> get cachedItems => _cachedItems;
  List<ManuverProgressModel> get cachedProgressItems => _cachedProgressItems;
  List<Map<String, dynamic>> get cachedDrafts => _cachedDrafts;
  List<Map<String, dynamic>> get cachedProgressDrafts => _cachedProgressDrafts;

  OpgiManuverCubit(this._repository) : super(OpgiManuverInitial());

  /// Memuat daftar kegiatan manuver untuk Gardu Induk tertentu beserta draft lokalnya
  Future<void> loadManuverList(
    int garduIndukId,
    String garduIndukNama, {
    String? timezone,
    bool forceRefresh = false,
  }) async {
    if (_cachedItems.isEmpty) {
      emit(OpgiManuverLoading());
    }
    try {
      final items = await _repository.getManuverList(
        garduIndukId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      final drafts = await LocalDatabase.instance.getUnfinishItemGi(
        nama: garduIndukNama,
        type: 'manuver',
      );
      _cachedItems = items;
      _cachedDrafts = drafts;
      emit(OpgiManuverLoaded(items, drafts: drafts));
    } catch (e) {
      if (_cachedItems.isNotEmpty) {
        emit(OpgiManuverLoaded(_cachedItems, drafts: _cachedDrafts));
      }
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(OpgiManuverError(errorMsg));
    }
  }

  /// Alias loadHistory untuk kompatibilitas
  Future<void> loadHistory(int garduIndukId, {String? timezone, String? nama}) async {
    return loadManuverList(garduIndukId, nama ?? '', timezone: timezone);
  }

  /// Memuat riwayat progress untuk manuver tertentu beserta draft lokalnya
  Future<void> loadManuverProgress(
    int manuverId,
    String draftKey, {
    String? timezone,
    bool forceRefresh = false,
  }) async {
    if (_cachedProgressItems.isEmpty) {
      emit(OpgiManuverLoading());
    }
    try {
      final items = await _repository.getManuverProgress(
        manuverId,
        timezone: timezone,
        forceRefresh: forceRefresh,
      );
      final drafts = await LocalDatabase.instance.getUnfinishItemGi(
        nama: draftKey,
        type: 'manuver-progress',
      );
      _cachedProgressItems = items;
      _cachedProgressDrafts = drafts;
      emit(OpgiManuverProgressLoaded(items, drafts: drafts));
    } catch (e) {
      if (_cachedProgressItems.isNotEmpty) {
        emit(OpgiManuverProgressLoaded(_cachedProgressItems, drafts: _cachedProgressDrafts));
      }
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(OpgiManuverError(errorMsg));
    }
  }

  /// Memuat daftar penyulang berdasarkan Gardu Induk
  Future<void> loadPenyulangList(int garduIndukId) async {
    emit(OpgiManuverLoading());
    try {
      final list = await _repository.getPenyulangByGi(garduIndukId);
      emit(OpgiManuverPenyulangLoaded(list));
    } catch (e) {
      emit(OpgiManuverError(e.toString()));
    }
  }

  /// Submit kegiatan manuver baru (Input Awal)
  Future<void> submitManuver(Map<String, dynamic> data, [dynamic file, int? draftId]) async {
    emit(OpgiManuverLoading());
    try {
      final response = await _repository.submitManuver(data, file);
      if (draftId != null) {
        await LocalDatabase.instance.removeFinishedItemGi(draftId);
      }
      await LocalDatabase.instance.deleteApiCachePattern('%manuver%');
      final msg = response['message']?.toString() ?? 'Kegiatan manuver berhasil disimpan';
      emit(OpgiManuverSuccess(msg, status: data['status']?.toString()));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(OpgiManuverError(errorMsg));
    }
  }

  /// Submit penambahan progress manuver
  Future<void> submitManuverProgress(Map<String, dynamic> data, [dynamic file, int? draftId]) async {
    emit(OpgiManuverLoading());
    try {
      final response = await _repository.submitManuverProgress(data, file);
      if (draftId != null) {
        await LocalDatabase.instance.removeFinishedItemGi(draftId);
      }
      await LocalDatabase.instance.deleteApiCachePattern('%manuver%');
      final msg = response['message']?.toString() ?? 'Progress manuver berhasil disimpan';
      emit(OpgiManuverSuccess(msg, status: data['status']?.toString()));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(OpgiManuverError(errorMsg));
    }
  }

  /// Update progress manuver
  Future<void> updateManuverProgress(int id, Map<String, dynamic> data) async {
    emit(OpgiManuverLoading());
    try {
      final response = await _repository.updateManuverProgress(id, data);
      await LocalDatabase.instance.deleteApiCachePattern('%manuver%');
      final msg = response['message']?.toString() ?? 'Progress manuver berhasil diupdate';
      emit(OpgiManuverSuccess(msg, status: data['status']?.toString()));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(OpgiManuverError(errorMsg));
    }
  }

  /// Hapus kegiatan manuver dengan optimistic delete & feedback instan
  Future<void> deleteManuver(int id, int garduIndukId, String garduIndukNama) async {
    final prevItems = List<ManuverItemModel>.from(_cachedItems);
    // 1. Optimistic removal: hapus seketika dari memori & emit state loaded
    _cachedItems = _cachedItems.where((m) => m.id != id).toList();
    emit(OpgiManuverLoaded(List.from(_cachedItems), drafts: _cachedDrafts));

    try {
      // 2. Clear cache lokal
      await LocalDatabase.instance.deleteApiCachePattern('%manuver%');

      // 3. Delete di server
      final res = await _repository.deleteManuver(id);
      final msg = res['message']?.toString() ?? 'Kegiatan manuver berhasil dihapus';

      // 4. Background refresh data server secara senyap tanpa emit loading
      try {
        final items = await _repository.getManuverList(
          garduIndukId,
          forceRefresh: true,
        );
        final drafts = await LocalDatabase.instance.getUnfinishItemGi(
          nama: garduIndukNama,
          type: 'manuver',
        );
        _cachedItems = items;
        _cachedDrafts = drafts;
      } catch (_) {
        // Abaikan jika background sync gagal, list tetap terupdate optimistik
      }

      emit(OpgiManuverLoaded(List.from(_cachedItems), drafts: _cachedDrafts));
      emit(OpgiManuverSuccess(msg, items: _cachedItems, drafts: _cachedDrafts));
    } catch (e) {
      // Rollback jika gagal
      _cachedItems = prevItems;
      emit(OpgiManuverLoaded(List.from(_cachedItems), drafts: _cachedDrafts));
      final errorMsg = _parseErrorMessage(e);
      emit(OpgiManuverError(errorMsg, items: _cachedItems, drafts: _cachedDrafts));
    }
  }

  /// Hapus progress manuver dengan optimistic delete & feedback instan
  Future<void> deleteManuverProgress(int id, int manuverId, String draftKey) async {
    final prevItems = List<ManuverProgressModel>.from(_cachedProgressItems);
    // 1. Optimistic removal: hapus seketika dari memori & emit state loaded
    _cachedProgressItems = _cachedProgressItems.where((p) => p.id != id).toList();
    emit(OpgiManuverProgressLoaded(List.from(_cachedProgressItems), drafts: _cachedProgressDrafts));

    try {
      // 2. Clear cache lokal
      await LocalDatabase.instance.deleteApiCachePattern('%manuver%');

      // 3. Delete di server
      final res = await _repository.deleteManuverProgress(id);
      final msg = res['message']?.toString() ?? 'Progress manuver berhasil dihapus';

      // 4. Background refresh data server secara senyap tanpa emit loading
      try {
        final items = await _repository.getManuverProgress(
          manuverId,
          forceRefresh: true,
        );
        final drafts = await LocalDatabase.instance.getUnfinishItemGi(
          nama: draftKey,
          type: 'manuver-progress',
        );
        _cachedProgressItems = items;
        _cachedProgressDrafts = drafts;
      } catch (_) {
        // Abaikan jika background sync gagal, list tetap terupdate optimistik
      }

      emit(OpgiManuverProgressLoaded(List.from(_cachedProgressItems), drafts: _cachedProgressDrafts));
      emit(OpgiManuverSuccess(msg, progressItems: _cachedProgressItems, drafts: _cachedProgressDrafts));
    } catch (e) {
      // Rollback jika gagal
      _cachedProgressItems = prevItems;
      emit(OpgiManuverProgressLoaded(List.from(_cachedProgressItems), drafts: _cachedProgressDrafts));
      final errorMsg = _parseErrorMessage(e);
      emit(OpgiManuverError(errorMsg, progressItems: _cachedProgressItems, drafts: _cachedProgressDrafts));
    }
  }

  String _parseErrorMessage(dynamic e) {
    if (e is ServerException) {
      if (e.statusCode == 403) {
        return 'Akses ditolak (403 Forbidden): Akun Anda tidak memiliki izin untuk menghapus data manuver di server.';
      }
      return e.message;
    }
    final raw = e.toString().replaceFirst('Exception: ', '');
    if (raw.contains('403') || raw.toLowerCase().contains('forbidden')) {
      return 'Akses ditolak (403 Forbidden): Akun Anda tidak memiliki izin untuk menghapus data manuver di server.';
    }
    return raw;
  }

  /// Simpan draft kegiatan manuver baru ke SQLite
  Future<void> saveDraftManuver({
    required String nama,
    required Map<String, dynamic> data,
  }) async {
    final nowStr = DateFormat('dd-MMMM-yyyy').format(DateTime.now());
    await LocalDatabase.instance.addUnfinishItemGi(
      nama: nama,
      date: nowStr,
      type: 'manuver',
      periode: 0,
      data: data,
    );
  }

  /// Simpan draft progress manuver ke SQLite
  Future<void> saveDraftManuverProgress({
    required String nama,
    required Map<String, dynamic> data,
  }) async {
    final nowStr = DateFormat('dd-MMMM-yyyy').format(DateTime.now());
    await LocalDatabase.instance.addUnfinishItemGi(
      nama: nama,
      date: nowStr,
      type: 'manuver-progress',
      periode: 0,
      data: data,
    );
  }

  /// Hapus draft berdasarkan ID
  Future<void> removeDraft(int id) async {
    await LocalDatabase.instance.removeFinishedItemGi(id);
  }
}

