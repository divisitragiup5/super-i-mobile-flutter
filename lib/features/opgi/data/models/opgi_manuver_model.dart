/// Model data manuver jaringan 20kV
class ManuverModel {
  final int? id;
  final int garduIndukId;
  final String namaPeralatan;
  final String tindakan; // 'BUKA' | 'TUTUP' | 'LEPAS' | 'MASUK'
  final String waktuManuver;
  final String? pelaksana;
  final String? dispatcher;
  final String status; // 'OPEN' | 'ON_PROGRESS' | 'DONE'
  final String? keterangan;

  const ManuverModel({
    this.id,
    required this.garduIndukId,
    required this.namaPeralatan,
    required this.tindakan,
    required this.waktuManuver,
    this.pelaksana,
    this.dispatcher,
    this.status = 'OPEN',
    this.keterangan,
  });

  factory ManuverModel.fromJson(Map<String, dynamic> json) {
    return ManuverModel(
      id: json['id'] as int?,
      garduIndukId: json['garduIndukId'] as int? ?? 0,
      namaPeralatan: json['namaPeralatan'] as String? ?? '-',
      tindakan: json['tindakan'] as String? ?? 'BUKA',
      waktuManuver: json['waktuManuver'] as String? ?? json['waktu'] as String? ?? '',
      pelaksana: json['pelaksana'] as String?,
      dispatcher: json['dispatcher'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'garduIndukId': garduIndukId,
        'namaPeralatan': namaPeralatan,
        'tindakan': tindakan,
        'waktuManuver': waktuManuver,
        if (pelaksana != null) 'pelaksana': pelaksana,
        if (dispatcher != null) 'dispatcher': dispatcher,
        'status': status,
        if (keterangan != null) 'keterangan': keterangan,
      };
}
