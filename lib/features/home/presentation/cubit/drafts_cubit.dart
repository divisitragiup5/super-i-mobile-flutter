import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_database.dart';

abstract class DraftsState extends Equatable {
  const DraftsState();

  @override
  List<Object?> get props => [];
}

class DraftsInitial extends DraftsState {}

class DraftsLoading extends DraftsState {}

class DraftsLoaded extends DraftsState {
  final List<Map<String, dynamic>> drafts;

  const DraftsLoaded({required this.drafts});

  @override
  List<Object?> get props => [drafts];
}

class DraftsError extends DraftsState {
  final String message;

  const DraftsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DraftsCubit extends Cubit<DraftsState> {
  DraftsCubit() : super(DraftsInitial());

  Future<void> loadDrafts() async {
    try {
      final List<Map<String, dynamic>> allDrafts = [];

      // 1. Ambil draft Line Walker (Waterpass, Pembumian, PPL, Kegiatan Sosial)
      final lineWalkerDrafts = await LocalDatabase.instance.getUnfinishItems();
      for (final d in lineWalkerDrafts) {
        allDrafts.add({
          ...d,
          'isGi': false,
        });
      }

      // 2. Ambil draft Gardu Induk 20kV (Beban, IL1, Anomali, dsb.) jika ada
      try {
        final giDrafts = await LocalDatabase.instance.getUnfinishedItemsGI();
        for (final g in giDrafts) {
          allDrafts.add({
            ...g,
            'isGi': true,
          });
        }
      } catch (_) {}

      emit(DraftsLoaded(drafts: allDrafts));
    } catch (e) {
      emit(DraftsError(e.toString()));
    }
  }

  Future<void> deleteDraft(int id, {bool isGi = false}) async {
    try {
      if (isGi) {
        await LocalDatabase.instance.removeFinishedItemGi(id);
      } else {
        await LocalDatabase.instance.deleteUnfinishItem(id);
      }
      await loadDrafts();
    } catch (e) {
      emit(DraftsError(e.toString()));
    }
  }
}
