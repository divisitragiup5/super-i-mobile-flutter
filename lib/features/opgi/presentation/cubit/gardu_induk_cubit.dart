import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/gardu_induk_model.dart';
import '../../domain/repositories/opgi_repository.dart';

abstract class GarduIndukState extends Equatable {
  const GarduIndukState();
  @override
  List<Object?> get props => [];
}

class GarduIndukInitial extends GarduIndukState {}
class GarduIndukLoading extends GarduIndukState {}
class GarduIndukLoaded extends GarduIndukState {
  final List<GarduIndukModel> list;
  const GarduIndukLoaded(this.list);
  @override
  List<Object?> get props => [list];
}
class GarduIndukError extends GarduIndukState {
  final String message;
  const GarduIndukError(this.message);
  @override
  List<Object?> get props => [message];
}

class GarduIndukCubit extends Cubit<GarduIndukState> {
  final OpgiRepository _repository;

  GarduIndukCubit(this._repository) : super(GarduIndukInitial());

  Future<void> loadGarduInduk() async {
    emit(GarduIndukLoading());
    try {
      final list = await _repository.getGarduIndukList();
      emit(GarduIndukLoaded(list));
    } catch (e) {
      emit(GarduIndukError(e.toString()));
    }
  }
}
