import 'package:equatable/equatable.dart';
import '../../data/models/riwayat_absen_model.dart';

abstract class RiwayatAbsenState extends Equatable {
  const RiwayatAbsenState();

  @override
  List<Object?> get props => [];
}

class RiwayatAbsenInitial extends RiwayatAbsenState {}

class RiwayatAbsenLoading extends RiwayatAbsenState {}

class RiwayatAbsenLoaded extends RiwayatAbsenState {
  final List<RiwayatAbsenItemModel> items;
  final int? nextCursor;
  final bool isLoadingMore;

  const RiwayatAbsenLoaded({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  RiwayatAbsenLoaded copyWith({
    List<RiwayatAbsenItemModel>? items,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return RiwayatAbsenLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, nextCursor, isLoadingMore];
}

class RiwayatAbsenError extends RiwayatAbsenState {
  final String message;

  const RiwayatAbsenError(this.message);

  @override
  List<Object?> get props => [message];
}

// Upload document states
abstract class UploadDokumenState extends Equatable {
  const UploadDokumenState();

  @override
  List<Object?> get props => [];
}

class UploadDokumenInitial extends UploadDokumenState {}

class UploadDokumenLoading extends UploadDokumenState {}

class UploadDokumenSuccess extends UploadDokumenState {
  final String message;

  const UploadDokumenSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadDokumenError extends UploadDokumenState {
  final String message;

  const UploadDokumenError(this.message);

  @override
  List<Object?> get props => [message];
}
