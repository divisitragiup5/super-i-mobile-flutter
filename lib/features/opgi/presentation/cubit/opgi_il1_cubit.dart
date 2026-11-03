import 'dart:convert';
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

class Il1TrafoPsLoaded extends OpgiIl1State {
  final List<Il1TrafoPsItem> items;
  final List<Map<String, dynamic>> localDrafts;
  const Il1TrafoPsLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class Il1SipilLoaded extends OpgiIl1State {
  final List<Il1SipilItem> items;
  final List<Map<String, dynamic>> localDrafts;
  const Il1SipilLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
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

  OpgiIl1Cubit(this._repository) : super(OpgiIl1Initial());

  // 1. Kubikel
  Future<void> loadKubikel(int garduIndukId) async {
    emit(OpgiIl1Loading());
    try {
      final items = await _repository.getIl1KubikelInput(garduIndukId);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'il1-kubikel');
      emit(Il1KubikelLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

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

  // 2. Trafo PS
  Future<void> loadTrafoPs(int garduIndukId) async {
    emit(OpgiIl1Loading());
    try {
      final items = await _repository.getIl1TrafoPsInput(garduIndukId);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'il1-trafo-ps');
      emit(Il1TrafoPsLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

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

  // 3. Sipil
  Future<void> loadSipil(int garduIndukId) async {
    emit(OpgiIl1Loading());
    try {
      final items = await _repository.getIl1SipilInput(garduIndukId);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'il1-sipil');
      emit(Il1SipilLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiIl1Error(e.toString()));
    }
  }

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

  // Draft operations
  Future<void> saveDraft({
    required String type,
    required String nama,
    required String date,
    required Map<String, dynamic> data,
  }) async {
    await LocalDatabase.instance.insertUnfinishedItemGI({
      'nama': nama,
      'date': date,
      'type': type,
      'periode': 0,
      'data': jsonEncode(data),
    });
  }

  Future<void> deleteDraft(int draftId) async {
    await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
  }
}
