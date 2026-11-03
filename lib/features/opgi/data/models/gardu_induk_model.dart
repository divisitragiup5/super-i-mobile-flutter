/// Model data aset Gardu Induk 20kV
class GarduIndukModel {
  final int id;
  final String nama;
  final String? kode;
  final String? date;

  const GarduIndukModel({
    required this.id,
    required this.nama,
    this.kode,
    this.date,
  });

  factory GarduIndukModel.fromJson(Map<String, dynamic> json) {
    return GarduIndukModel(
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? json['name'] as String? ?? '-',
      kode: json['kode'] as String?,
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'kode': kode,
        'date': date,
      };
}
