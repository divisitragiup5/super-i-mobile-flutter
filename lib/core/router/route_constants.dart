/// Daftar nama rute (path) yang tersedia di seluruh aplikasi Super-I.
class AppRoutes {
  AppRoutes._();

  // 1. Auth & Entry
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';
  static const String akun = '/akun';
  static const String profile = '/profile';
  static const String ubahPassword = '/ubah-password';
  static const String notification = '/notification';

  // 2. Presensi (Absen)
  static const String absen = '/absen';
  static const String absenProcessing = '/absen-processing';
  static const String riwayatAbsen = '/riwayat-absen';
  static const String riwayatAbsenDetail = '/riwayat-absen-detail';
  static const String riwayatAbsenUpdate = '/riwayat-absen-update';
  static const String dataShift = '/data-shift';
  static const String historyPenilaian = '/history-penilaian';
  static const String detailHistoryPenilaian = '/detail-history-penilaian';

  // 3. Modul Line Walker (Transmisi SUTT / SUTET)
  static const String waterpass = '/waterpass';
  static const String riwayatWaterpassDetail = '/riwayat-waterpass-detail';

  static const String pembumian = '/pembumian';
  static const String summaryPembumian = '/summary-pembumian';
  static const String riwayatPembumian = '/riwayat-pembumian';
  static const String riwayatPembumianDetail = '/riwayat-pembumian-detail';

  static const String ppl = '/ppl';
  static const String updatePpl = '/update-ppl';
  static const String summaryPpl = '/summary-ppl';
  static const String riwayatPpl = '/riwayat-ppl';
  static const String riwayatPplList = '/riwayat-ppl-list';
  static const String riwayatPplDetail = '/riwayat-ppl-detail';
  static const String summaryRiwayatPpl = '/summary-riwayat-ppl';

  static const String ketenagakerjaan = '/ketenagakerjaan';
  static const String summaryKetenagakerjaan = '/summary-ketenagakerjaan';
  static const String ketenagakerjaanDetail = '/ketenagakerjaan-detail';

  static const String kegiatanSosial = '/kegiatan-sosial';
  static const String updateKegiatanSosial = '/update-kegiatan-sosial';
  static const String riwayatKegiatanSosial = '/riwayat-kegiatan-sosial';
  static const String riwayatKegiatanSosialList = '/riwayat-kegiatan-sosial-list';
  static const String riwayatKegiatanSosialDetail = '/riwayat-kegiatan-sosial-detail';

  // 4. Modul Distribusi SUTM
  static const String workorderInspeksi = '/workorder-inspeksi';
  static const String detailWorkorder = '/detail-workorder';
  static const String detailWorkorderToday = '/detail-workorder-today';
  static const String ruteInspeksi = '/rute-inspeksi';
  static const String detailSutm = '/detail-sutm';
  static const String inspeksiForm = '/inspeksi-form';
  static const String validasiInspeksi = '/validasi-inspeksi';
  static const String validasiDetailWorkorder = '/validasi-detail-workorder';
  static const String riwayatInspeksi = '/riwayat-inspeksi';

  static const String workorderPemeliharaan = '/workorder-pemeliharaan';
  static const String detailWorkorderPemeliharaan = '/detail-workorder-pemeliharaan';
  static const String detailWorkorderPemeliharaanToday = '/detail-workorder-pemeliharaan-today';
  static const String rutePemeliharaan = '/rute-pemeliharaan';
  static const String detailSutmPemeliharaan = '/detail-sutm-pemeliharaan';
  static const String inspeksiPemeliharaanForm = '/inspeksi-pemeliharaan-form';
  static const String validasiPemeliharaan = '/validasi-pemeliharaan';
  static const String riwayatPemeliharaan = '/riwayat-pemeliharaan';

  static const String inspeksiYantek = '/inspeksi-yantek';
  static const String inspeksiYantekDetailSutm = '/inspeksi-yantek-detail-sutm';
  static const String inspeksiYantekInspeksiForm = '/inspeksi-yantek-inspeksi-form';

  static const String riwayatPenilaianInspeksi = '/riwayat-penilaian-inspeksi';
  static const String detailRiwayatPenilaianInspeksi = '/detail-riwayat-penilaian-inspeksi';
  static const String riwayatPenilaianHar = '/riwayat-penilaian-har';
  static const String detailRiwayatPenilaianHar = '/detail-riwayat-penilaian-har';

  // 5. Modul OPGI 20kV & Gardu Induk
  static const String garduInduk20kv = '/gardu-induk-20kv';
  static const String inputRealisasi = '/input-realisasi';

  static const String bebanTrafo = '/beban-trafo';
  static const String dataBebanTrafo = '/data-beban-trafo';
  static const String inputBebanTrafo = '/input-beban-trafo';
  static const String updateBebanTrafo = '/update-beban-trafo';

  static const String bebanPenyulang = '/beban-penyulang';
  static const String dataBebanPenyulang = '/data-beban-penyulang';
  static const String inputBebanPenyulang = '/input-beban-penyulang';
  static const String updateBebanPenyulang = '/update-beban-penyulang';
  static const String updateUrutanPenyulang = '/update-urutan-penyulang';

  static const String kwhHarian = '/kwh-harian';
  static const String dataKwhHarian = '/data-kwh-harian';
  static const String inputKwhHarian = '/input-kwh-harian';
  static const String updateKwhHarian = '/update-kwh-harian';

  static const String teganganTrafo = '/tegangan-trafo';
  static const String dataTeganganTrafo = '/data-tegangan-trafo';
  static const String inputTeganganTrafo = '/input-tegangan-trafo';
  static const String updateTeganganTrafo = '/update-tegangan-trafo';

  static const String manuver = '/manuver';
  static const String dataManuver = '/data-manuver';
  static const String inputManuver = '/input-manuver';
  static const String inputManuverProgress = '/input-manuver-progress';
  static const String updateManuverProgress = '/update-manuver-progress';

  static const String anomaliGi = '/anomali-gi';
  static const String dataAnomaliGi = '/data-anomali-gi';
  static const String inputAnomaliGi = '/input-anomali-gi';
  static const String inputKondisiAnomaliGi = '/input-kondisi-anomali-gi';
  static const String updateKondisiAnomaliGi = '/update-kondisi-anomali-gi';

  static const String il1 = '/il-1';
  static const String il1Kubikel = '/il1-kubikel';
  static const String dataIl1Kubikel = '/data-il1-kubikel';
  static const String inputIl1Kubikel = '/input-il1-kubikel';
  static const String updateIl1Kubikel = '/update-il1-kubikel';

  static const String il1TrafoPs = '/il1-trafo-ps';
  static const String dataIl1TrafoPs = '/data-il1-trafo-ps';
  static const String inputIl1TrafoPs = '/input-il1-trafo-ps';
  static const String updateIl1TrafoPs = '/update-il1-trafo-ps';

  static const String il1Sipil = '/il1-sipil';
  static const String dataIl1Sipil = '/data-il1-sipil';
  static const String inputIl1Sipil = '/input-il1-sipil';
  static const String updateIl1Sipil = '/update-il1-sipil';

  // Aliases for camelCase consistency
  static const String detailWorkOrderToday = detailWorkorderToday;
  static const String detailWorkOrderPemeliharaanToday = detailWorkorderPemeliharaanToday;
}

typedef RouteConstants = AppRoutes;
