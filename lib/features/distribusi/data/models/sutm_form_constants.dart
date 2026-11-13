/// Konstanta dan opsi formulir inspeksi komponen Distribusi SUTM sesuai super-i-mobile
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

  static const List<String> pdOptions = [
    'Baik',
    'Kurang Baik',
  ];

  // 3. Sub Isolator
  static const List<String> jenisIsolatorTm13Options = [
    'Pin Post',
    'Line Post',
  ];

  static const List<String> jenisIsolatorTm5Options = [
    'Suspension',
    'Pin Post',
    'Line Post',
  ];

  static const List<String> kondisiIsolatorOptions = [
    'Baik',
    'Flash Over',
    'Pecah',
    'Kotor',
    'Retak Rambut',
    'Korosi Pin/Cap',
  ];

  static const List<String> topTiesOptions = [
    'Baik',
    'Kendor',
    'Lepas',
    'Tidak Ada',
  ];

  static const List<String> crossArmOptions = [
    'Baik',
    'Miring',
    'Korosi Ringan',
    'Korosi Berat',
    'Bengkuk',
  ];

  static const List<String> armTieOptions = [
    'Baik',
    'Korosi Ringan',
    'Korosi Berat',
    'Kendor',
    'Lepas',
    'Bengkuk',
    'Patah',
  ];

  static const List<String> sambunganJumperOptions = [
    'PG Clamp',
    'C-Wedge',
    'Joint Sleeve',
    'Kompresi',
    'Tidak Ada',
  ];

  // 4. Sub Proteksi & Pembumian
  static const List<String> gswLetakOptions = [
    'Puncak Tiang',
    'Bawah Fasa',
    'Tidak Ada',
  ];

  static const List<String> kondisiGswOptions = [
    'Baik',
    'Rantas',
    'Korosi',
  ];

  static const List<String> hasArresterOptions = [
    'Ada',
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

  static const List<String> jumperArresterOptions = [
    'Baik',
    'Korosi',
    'Rantas',
    'Putus',
    'Lepas',
  ];

  static const List<String> kawatPembumianOptions = [
    'Ada',
    'Tidak Ada',
  ];

  static const List<String> groundingOptions = [
    'Baik',
    'Putus',
    'Korosi',
    'Hilang',
    'Tidak Terpasang',
    'Tidak Ada',
  ];

  // 5. Sub Konstruksi Penopang (Aksesoris)
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
    'Hilang',
  ];

  static const List<String> kondisiSteelWireOptions = [
    'Baik',
    'Kendor',
    'Korosi',
    'Putus',
  ];

  static const List<String> pondasiOptions = [
    'Baik',
    'Retak',
    'Amblas',
    'Tertimbun',
  ];

  // 6. Sub Peralatan Hubung (Switching)
  static const List<String> fcoOptions = [
    'Ada',
    'Tidak Ada',
  ];

  static const List<String> sambunganFcoOptions = [
    'Baik',
    'Korosi',
    'Kendor',
    'Lepas',
    'Tidak Ada',
  ];

  static const List<String> lbsKonvensionalOptions = [
    'Baik',
    'Rusak',
    'Tidak Ada',
  ];

  static const List<String> lbsRemoteOptions = [
    'Baik',
    'Rusak',
    'Tidak Ada',
  ];

  static const List<String> recloserOptions = [
    'Baik',
    'Rusak',
    'Tidak Ada',
  ];

  // 7. Sub ROW & Lingkungan
  static const List<String> rowJenisEntitasOptions = [
    'Pohon',
    'Bangunan',
    'Reklame/Baliho',
    'Antena',
    'Umbul-umbul/Bendera',
    'Lainnya',
  ];

  static const List<String> rowJarakOptions = [
    '< 2.5 Meter',
    '>= 2.5 Meter',
  ];

  static const List<String> rowPhasaOptions = [
    'R',
    'S',
    'T',
    'Netral',
    'Semua Fasa',
  ];

  // Aliases for compatibility
  static const List<String> kondisiTopTiesOptions = topTiesOptions;
  static const List<String> kondisiCrossArmOptions = crossArmOptions;
  static const List<String> kondisiArmTieOptions = armTieOptions;
  static const List<String> arresterOptions = hasArresterOptions;
  static const List<String> penopangJenisOptions = jenisPenopangOptions;
  static const List<String> penopangKondisiOptions = kondisiPenopangOptions;
  static const List<String> jenisEntitasOptions = rowJenisEntitasOptions;
  static const List<String> jarakOptions = rowJarakOptions;
  static const List<String> fasaRowOptions = rowPhasaOptions;
}
