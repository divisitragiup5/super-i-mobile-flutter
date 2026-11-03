class KetentuanShiftModel {
  final String? identifier;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  KetentuanShiftModel({
    this.identifier,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  factory KetentuanShiftModel.fromJson(Map<String, dynamic> json) {
    return KetentuanShiftModel(
      identifier: json['identifier'] as String?,
      startHour: json['startHour'] as int?,
      startMinute: json['startMinute'] as int?,
      endHour: json['endHour'] as int?,
      endMinute: json['endMinute'] as int?,
    );
  }
}

class ShiftItemModel {
  final int id;
  final int tanggal;
  final int bulan;
  final int tahun;
  final KetentuanShiftModel? ketentuan;
  final String? statusJadwal;
  final bool bisaDiganti;

  ShiftItemModel({
    required this.id,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    this.ketentuan,
    this.statusJadwal,
    this.bisaDiganti = false,
  });

  bool get isOngoing {
    if (ketentuan == null) return false;
    final now = DateTime.now();
    final start = DateTime(
      tahun,
      bulan + 1,
      tanggal,
      ketentuan!.startHour ?? 0,
      ketentuan!.startMinute ?? 0,
    );
    final end = DateTime(
      tahun,
      bulan + 1,
      tanggal,
      ketentuan!.endHour ?? 0,
      ketentuan!.endMinute ?? 0,
    );
    return now.isAfter(start) && now.isBefore(end);
  }

  bool get isPassed {
    if (ketentuan == null) return false;
    final now = DateTime.now();
    final end = DateTime(
      tahun,
      bulan + 1,
      tanggal,
      ketentuan!.endHour ?? 0,
      ketentuan!.endMinute ?? 0,
    );
    return now.isAfter(end);
  }

  bool get canBeSwapped {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final shiftDate = DateTime(tahun, bulan + 1, tanggal);
    return bisaDiganti && (shiftDate.isAfter(startOfToday) || shiftDate.isAtSameMomentAs(startOfToday));
  }

  factory ShiftItemModel.fromJson(Map<String, dynamic> json) {
    return ShiftItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      tanggal: json['tanggal'] as int? ?? 1,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? DateTime.now().year,
      ketentuan: json['ketentuan'] != null && json['ketentuan'] is Map<String, dynamic>
          ? KetentuanShiftModel.fromJson(json['ketentuan'])
          : null,
      statusJadwal: json['statusJadwal'] as String?,
      bisaDiganti: json['bisaDiganti'] as bool? ?? false,
    );
  }
}
