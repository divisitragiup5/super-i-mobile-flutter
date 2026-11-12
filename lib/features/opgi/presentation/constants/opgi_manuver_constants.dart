class OpgiManuverOption {
  final String label;
  final String value;
  final String? objek;

  const OpgiManuverOption({
    required this.label,
    required this.value,
    this.objek,
  });
}

class OpgiManuverConstants {
  OpgiManuverConstants._();

  static const List<OpgiManuverOption> tipeManuver = [
    OpgiManuverOption(label: 'Gangguan', value: 'GANGGUAN'),
    OpgiManuverOption(label: 'Pekerjaan', value: 'PEKERJAAN'),
    OpgiManuverOption(label: 'Trip Overload', value: 'TRIP OVERLOAD'),
  ];

  static const List<OpgiManuverOption> objek = [
    OpgiManuverOption(label: 'PMT', value: 'PMT'),
    OpgiManuverOption(label: 'PMS RELL + KABEL', value: 'PMS RELL + KABEL'),
    OpgiManuverOption(label: 'PMS TANAH', value: 'PMS TANAH'),
  ];

  static const List<OpgiManuverOption> status = [
    OpgiManuverOption(label: 'Open', value: 'OPEN', objek: 'PMT'),
    OpgiManuverOption(label: 'Close', value: 'CLOSE', objek: 'PMT'),
    OpgiManuverOption(label: 'Rack In', value: 'RACK IN', objek: 'PMS RELL + KABEL'),
    OpgiManuverOption(label: 'Rack Out', value: 'RACK OUT', objek: 'PMS RELL + KABEL'),
    OpgiManuverOption(label: 'Keluar', value: 'KELUAR', objek: 'PMS TANAH'),
    OpgiManuverOption(label: 'Masuk', value: 'MASUK', objek: 'PMS TANAH'),
  ];

  static const List<OpgiManuverOption> posisi = [
    OpgiManuverOption(label: 'Trip', value: 'TRIP', objek: 'PMT'),
    OpgiManuverOption(label: 'Rack In', value: 'RACK IN', objek: 'PMS RELL + KABEL'),
    OpgiManuverOption(label: 'Rack Out', value: 'RACK OUT', objek: 'PMS RELL + KABEL'),
    OpgiManuverOption(label: 'Masuk', value: 'MASUK', objek: 'PMS TANAH'),
    OpgiManuverOption(label: 'Keluar', value: 'KELUAR', objek: 'PMS TANAH'),
  ];

  static const List<String> jenisGangguan = [
    'GFM',
    'GF',
    'OCM',
    'OC',
    'UFR',
  ];

  static const List<OpgiManuverOption> operasi = [
    OpgiManuverOption(label: 'Local', value: 'LOCAL'),
    OpgiManuverOption(label: 'Remote', value: 'REMOTE'),
  ];

  static const List<String> typeArus = [
    'Ia',
    'Ib',
    'Ic',
    'In',
  ];

  static const List<String> satuanArus = [
    'A',
    'kA',
  ];

  /// Mendapatkan daftar status yang valid sesuai objek yang dipilih
  static List<OpgiManuverOption> getStatusForObjek(String? selectedObjek, {bool excludeClose = false}) {
    if (selectedObjek == null || selectedObjek.isEmpty) return const [];
    return status.where((s) {
      if (s.objek != selectedObjek) return false;
      if (excludeClose && s.value == 'CLOSE') return false;
      return true;
    }).toList();
  }

  /// Mendapatkan daftar posisi yang valid sesuai objek yang dipilih
  static List<OpgiManuverOption> getPosisiForObjek(String? selectedObjek) {
    if (selectedObjek == null || selectedObjek.isEmpty) return const [];
    return posisi.where((p) => p.objek == selectedObjek).toList();
  }
}
