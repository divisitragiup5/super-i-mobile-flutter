import 'package:equatable/equatable.dart';
import '../../data/models/history_penilaian_model.dart';

abstract class HistoryPenilaianState extends Equatable {
  const HistoryPenilaianState();

  @override
  List<Object?> get props => [];
}

class HistoryPenilaianInitial extends HistoryPenilaianState {}

class HistoryPenilaianLoading extends HistoryPenilaianState {}

class HistoryPenilaianLoaded extends HistoryPenilaianState {
  final List<NilaiBulananItemModel> items;
  final int? nextCursor;
  final bool isLoadingMore;

  const HistoryPenilaianLoaded({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  HistoryPenilaianLoaded copyWith({
    List<NilaiBulananItemModel>? items,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return HistoryPenilaianLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, nextCursor, isLoadingMore];
}

class HistoryPenilaianError extends HistoryPenilaianState {
  final String message;

  const HistoryPenilaianError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Detail History States ──
abstract class DetailHistoryPenilaianState extends Equatable {
  const DetailHistoryPenilaianState();

  @override
  List<Object?> get props => [];
}

class DetailHistoryPenilaianInitial extends DetailHistoryPenilaianState {}

class DetailHistoryPenilaianLoading extends DetailHistoryPenilaianState {}

class DetailHistoryPenilaianLoaded extends DetailHistoryPenilaianState {
  final List<NilaiHarianItemModel> harianItems;
  final GrafikBulananModel? grafik;

  const DetailHistoryPenilaianLoaded({
    required this.harianItems,
    this.grafik,
  });

  @override
  List<Object?> get props => [harianItems, grafik];
}

class DetailHistoryPenilaianError extends DetailHistoryPenilaianState {
  final String message;

  const DetailHistoryPenilaianError(this.message);

  @override
  List<Object?> get props => [message];
}
