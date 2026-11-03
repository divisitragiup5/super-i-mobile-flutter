class TowerAssetModel {
  final int id;
  final String nama;
  final String? nomor;
  final String? type;

  TowerAssetModel({
    required this.id,
    required this.nama,
    this.nomor,
    this.type,
  });

  factory TowerAssetModel.fromJson(Map<String, dynamic> json) {
    return TowerAssetModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      nama: json['nama']?.toString() ?? json['nomor']?.toString() ?? 'Tower',
      nomor: json['nomor']?.toString(),
      type: json['type']?.toString(),
    );
  }
}
