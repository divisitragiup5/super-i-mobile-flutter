import 'dart:convert';
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

class BebanPenyulangLoaded extends OpgiRealisasiState {
  final List<BebanPenyulangModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const BebanPenyulangLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class KwhHarianLoaded extends OpgiRealisasiState {
  final List<KwhHarianModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const KwhHarianLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class TeganganTrafoLoaded extends OpgiRealisasiState {
  final List<TeganganTrafoModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const TeganganTrafoLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
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

  OpgiRealisasiCubit(this._repository) : super(OpgiRealisasiInitial());

  // 1. Beban Trafo
  Future<void> loadBebanTrafo(int garduIndukId, String date) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getBebanTrafoInput(garduIndukId, date);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'beban-trafo',
        date: date,
      );
      emit(BebanTrafoLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, {String timezone = 'Asia/Jakarta'}) async {
    emit(OpgiRealisasiLoading());
    try {
      await _repository.submitBebanTrafo(garduIndukId, items, timezone);
      // Bersihkan draft terkait
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'beban-trafo');
      for (final d in drafts) {
        if (d['id'] != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(d['id'] as int);
        }
      }
      emit(const OpgiRealisasiSuccess('Data Beban Trafo berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // 2. Beban Penyulang
  Future<void> loadBebanPenyulang(int garduIndukId, String date) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getBebanPenyulangInput(garduIndukId, date);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'beban-penyulang',
        date: date,
      );
      emit(BebanPenyulangLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, {String timezone = 'Asia/Jakarta'}) async {
    emit(OpgiRealisasiLoading());
    try {
      await _repository.submitBebanPenyulang(garduIndukId, items, timezone);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'beban-penyulang');
      for (final d in drafts) {
        if (d['id'] != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(d['id'] as int);
        }
      }
      emit(const OpgiRealisasiSuccess('Data Beban Penyulang berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) async {
    emit(OpgiRealisasiLoading());
    try {
      await _repository.updateUrutanPenyulang(garduIndukId, items);
      emit(const OpgiRealisasiSuccess('Urutan Penyulang berhasil diperbarui'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // 3. Kwh Harian
  Future<void> loadKwhHarian(int garduIndukId, String date) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getKwhHarianInput(garduIndukId, date);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'kwh-harian',
        date: date,
      );
      emit(KwhHarianLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, {String timezone = 'Asia/Jakarta'}) async {
    emit(OpgiRealisasiLoading());
    try {
      await _repository.submitKwhHarian(garduIndukId, items, timezone);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'kwh-harian');
      for (final d in drafts) {
        if (d['id'] != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(d['id'] as int);
        }
      }
      emit(const OpgiRealisasiSuccess('Data KWH Harian berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // 4. Tegangan Trafo
  Future<void> loadTeganganTrafo(int garduIndukId, String date) async {
    emit(OpgiRealisasiLoading());
    try {
      final items = await _repository.getTeganganTrafoInput(garduIndukId, date);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        type: 'tegangan-trafo',
        date: date,
      );
      emit(TeganganTrafoLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, {String timezone = 'Asia/Jakarta'}) async {
    emit(OpgiRealisasiLoading());
    try {
      await _repository.submitTeganganTrafo(garduIndukId, items, timezone);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'tegangan-trafo');
      for (final d in drafts) {
        if (d['id'] != null) {
          await LocalDatabase.instance.deleteUnfinishedItemGI(d['id'] as int);
        }
      }
      emit(const OpgiRealisasiSuccess('Data Tegangan Trafo berhasil disimpan'));
    } catch (e) {
      emit(OpgiRealisasiError(e.toString()));
    }
  }

  // Save / Delete offline draft
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
