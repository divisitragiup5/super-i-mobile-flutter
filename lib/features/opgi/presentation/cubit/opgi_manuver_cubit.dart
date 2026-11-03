import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
  final List<ManuverModel> items;
  const OpgiManuverLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class OpgiManuverSuccess extends OpgiManuverState {
  final String message;
  const OpgiManuverSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class OpgiManuverError extends OpgiManuverState {
  final String message;
  const OpgiManuverError(this.message);
  @override
  List<Object?> get props => [message];
}

class OpgiManuverCubit extends Cubit<OpgiManuverState> {
  final OpgiRepository _repository;

  OpgiManuverCubit(this._repository) : super(OpgiManuverInitial());

  Future<void> loadHistory(int garduIndukId, {int? cursor}) async {
    emit(OpgiManuverLoading());
    try {
      final items = await _repository.getManuverHistory(garduIndukId, cursor: cursor);
      emit(OpgiManuverLoaded(items));
    } catch (e) {
      emit(OpgiManuverError(e.toString()));
    }
  }

  Future<void> submitManuver(Map<String, dynamic> data) async {
    emit(OpgiManuverLoading());
    try {
      await _repository.submitManuver(data);
      emit(const OpgiManuverSuccess('Data manuver berhasil disimpan'));
    } catch (e) {
      emit(OpgiManuverError(e.toString()));
    }
  }

  Future<void> deleteManuver(int id, int garduIndukId) async {
    emit(OpgiManuverLoading());
    try {
      await _repository.deleteManuver(id);
      final items = await _repository.getManuverHistory(garduIndukId);
      emit(OpgiManuverLoaded(items));
    } catch (e) {
      emit(OpgiManuverError(e.toString()));
    }
  }
}
