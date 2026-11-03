/// Konstanta dan opsi formulir inspeksi komponen Distribusi SUTM
class SutmFormConstants {
  SutmFormConstants._();

  // Fasa List
  static const List<String> fasaList = ['R', 'S', 'T'];

  // 1. Sub Tiang
  static const List<String> jenisTiangOptions = [
    'Besi',
    'Beton',
    'Kayu',
    'Tiang Sambung',
  ];

  static const List<String> tinggiTiangOptions = [
    '9 Meter',
    '11 Meter',
    '12 Meter',
    '13 Meter',
    '14 Meter',
  ];

  static const List<String> kondisiTiangOptions = [
    'Baik',
    'Retak',
    'Korosi 20-40%',
    'Korosi 40-60%',
    'Miring',
  ];

  static const List<String> identitasTiangOptions = [
    'Ada',
    'Tidak Ada',
  ];

  static const List<String> jenisKonstruksiOptions = [
    'TM 1',
    'TM 3',
    'TM 5',
    'TM Awal',
    'TM Akhir',
    'Kombinasi',
  ];

  // 2. Sub Penghantar
  static const List<String> jenisKonduktorOptions = [
    'A3C',
    'A3CS',
    'MVTIC',
  ];

  static const List<String> ukuranKonduktorOptions = [
    '35mm',
    '70mm',
    '150mm',
    '240mm',
  ];

  static const List<String> kondisiKonduktorOptions = [
    'Baik',
    'Rantas 1-3 Urat',
    'Rantas > 3 Urat',
    'Andongan Kendor',
    'Benang Jahit Terburai',
    'Pelepasan Lapisan Isolasi',
    'Terkikis/Terbakar',
  ];

  static const List<String> sambunganKonduktorOptions = [
    'Ada',
    'Tidak Ada',
  ];

  static const List<String> terminasiOptions = [
    'Ada',
    'Tidak Ada',
  ];

  // 3. Sub Isolator
  static const List<String> kondisiIsolatorOptions = [
    'Baik',
    'Flash Over',
    'Pecah',
    'Kotor',
    'Retak Rambut',
    'Korosi Pin/Cap',
  ];

  static const List<String> jenisIsolatorOptions = [
    'Pin Post',
    'Line Post',
    'Suspension',
  ];

  static const List<String> topTiesOptions = [
    'Baik',
    'Kendor',
    'Lepas',
    'Tidak Ada',
  ];

  static const List<String> kondisiCrossArmOptions = [
    'Baik',
    'Miring',
    'Korosi Ringan',
    'Korosi Berat',
    'Bengkuk',
  ];

  // 4. Sub Proteksi & Pembumian
  static const List<String> gswLetakOptions = [
    'Puncak Tiang',
    'Bawah Fasa',
    'Tidak Ada',
  ];

  static const List<String> jenisArresterOptions = [
    'Polymer',
    'Porcelain',
    'Tidak Ada',
  ];

  static const List<String> kondisiArresterOptions = [
    'Baik',
    'Pecah/Retak',
    'Flash Over',
    'Ground Lead Disconnector Putus',
  ];

  static const List<String> kondisiGroundingOptions = [
    'Baik',
    'Putus',
    'Korosi',
    'Hilang',
    'Tidak Terpasang',
  ];

  // 5. Sub Konstruksi Penopang
  static const List<String> jenisPenopangOptions = [
    'Guy Wire (Trikang)',
    'Strut Pole',
    'Span Wire',
    'Tidak Ada',
  ];

  static const List<String> kondisiPenopangOptions = [
    'Baik',
    'Kendor',
    'Korosi',
    'Pondasi Amblas',
  ];

  // 6. Sub Peralatan Hubung
  static const List<String> fcoOptions = [
    'Ada',
    'Tidak Ada',
  ];

  static const List<String> kondisiFcoOptions = [
    'Baik',
    'Tabung Fuse Jatuh/Lepas',
    'Isolator Pecah',
    'Konektor Korosi',
  ];

  static const List<String> lbsOptions = [
    'Ada',
    'Tidak Ada',
  ];

  static const List<String> recloserOptions = [
    'Ada',
    'Tidak Ada',
  ];

  // 7. Sub ROW & Lingkungan
  static const List<String> jenisPohonOptions = [
    'Keras',
    'Sedang',
    'Lunak',
    'Bambu',
    'Kelapa/Sawit',
  ];

  static const List<String> jarakRowOptions = [
    '< 1 Meter (Sangat Bahaya)',
    '1 - 2.5 Meter (Perlu Tebang)',
    '> 2.5 Meter (Aman)',
  ];

  static const List<String> jenisTindakanRowOptions = [
    'Pangkas Ranting',
    'Tebang Pohon',
    'Sosialisasi ROW',
  ];
}
