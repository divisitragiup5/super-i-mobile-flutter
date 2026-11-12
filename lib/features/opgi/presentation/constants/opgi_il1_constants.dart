import 'package:flutter/material.dart';

class DropdownOption {
  final String label;
  final String value;

  const DropdownOption({required this.label, required this.value});
}

class OpgiIl1Constants {
  // ===========================================================================
  // STATUS INPUT REALISASI & WARNA
  // ===========================================================================
  static const Map<String, Color> statusColors = {
    'SESUAI': Color(0xFF22C55E), // green 500
    'ANOMALI': Color(0xFFEF4444), // red 500
    'BELUM': Color(0xFF6B7280), // gray 500
    'DRAFT': Color(0xFFF97316), // orange 500
  };

  static Color getStatusColor(String? status) {
    if (status == null || status.isEmpty) return const Color(0xFF6B7280);
    return statusColors[status.toUpperCase()] ?? const Color(0xFF6B7280);
  }

  // ===========================================================================
  // IL1 KUBIKEL
  // ===========================================================================
  static const List<DropdownOption> kubikelCloseOpen = [
    DropdownOption(label: 'Close', value: 'CLOSE'),
    DropdownOption(label: 'Open', value: 'OPEN'),
  ];

  static const List<DropdownOption> kubikelRackInOut = [
    DropdownOption(label: 'Rack In', value: 'RACK IN'),
    DropdownOption(label: 'Rack Out', value: 'RACK OUT'),
  ];

  static const List<DropdownOption> kubikelKeteranganPMT = [
    DropdownOption(label: 'Timbul Tegangan', value: 'TIMBUL TEGANGAN'),
    DropdownOption(label: 'Gangguan', value: 'GANGGUAN'),
    DropdownOption(label: 'Normal', value: 'NORMAL'),
  ];

  static const List<DropdownOption> kubikelKondisiSF6 = [
    DropdownOption(label: 'Good', value: 'GOOD'),
    DropdownOption(label: 'Not Good', value: 'NOT GOOD'),
    DropdownOption(label: 'Warning', value: 'WARNING'),
  ];

  static const List<DropdownOption> kubikelPegasMekanik = [
    DropdownOption(label: 'Charge', value: 'CHARGE'),
    DropdownOption(label: 'Discharge', value: 'DISCHARGE'),
  ];

  static const List<DropdownOption> adaTidak = [
    DropdownOption(label: 'Ada', value: 'ADA'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> bersihTidak = [
    DropdownOption(label: 'Bersih', value: 'BERSIH'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> nyalaTidak = [
    DropdownOption(label: 'Nyala', value: 'NYALA'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> normalBlank = [
    DropdownOption(label: 'Normal', value: 'NORMAL'),
    DropdownOption(label: 'Blank', value: 'BLANK'),
  ];

  static const List<DropdownOption> relayUfrKeterangan = [
    DropdownOption(label: 'Ada', value: 'ADA'),
    DropdownOption(label: 'Tidak Ada', value: 'TIDAK ADA'),
  ];

  static const List<DropdownOption> selectorUfr = [
    DropdownOption(label: 'Tidak Ada', value: '0'),
    DropdownOption(label: '1', value: '1'),
    DropdownOption(label: '2', value: '2'),
    DropdownOption(label: '3', value: '3'),
  ];

  static const List<DropdownOption> kwhTombol = [
    DropdownOption(label: 'Normal', value: 'NORMAL'),
    DropdownOption(label: 'Rusak', value: 'RUSAK'),
  ];

  static const List<DropdownOption> alarmKondisi = [
    DropdownOption(label: 'Ada', value: 'ADA'),
    DropdownOption(label: 'Tidak Ada', value: 'TIDAK ADA'),
    DropdownOption(label: 'Tidak Berbunyi', value: 'TIDAK BERBUNYI'),
  ];

  static const List<DropdownOption> anomaliKeterangan = [
    DropdownOption(label: 'Ada', value: 'ADA'),
    DropdownOption(label: 'Tidak Ada', value: 'TIDAK ADA'),
  ];

  // ===========================================================================
  // IL1 TRAFO PS
  // ===========================================================================
  static const List<DropdownOption> trafoPsJenisTrafo = [
    DropdownOption(label: 'INDOOR', value: 'INDOOR'),
    DropdownOption(label: 'OUTDOOR', value: 'OUTDOOR'),
  ];

  static const List<DropdownOption> trafoPsKebocoranBody = [
    DropdownOption(
      label: 'Trafo Tidak Ada Kebocoran Di Body Trafo',
      value: 'TRAFO TIDAK ADA KEBOCORAN DI BODY TRAFO',
    ),
    DropdownOption(
      label: 'Salah Satu Part Ada Noda Rembes Tapi Tidak Menetes',
      value: 'SALAH SATU PART ADA NODA REMBES TAPI TIDAK MENETES',
    ),
    DropdownOption(
      label: 'Lebih Dari Satu Part Ada Noda Rembes Tapi Tidak Menetes',
      value: 'LEBIH DARI SATU PART ADA NODA REMBES TAPI TIDAK MENETES',
    ),
    DropdownOption(
      label: 'Body Ada Rembesan Dan Potensi Menetes Lambat',
      value: 'BODY ADA REMBESAN DAN POTENSI MENETES LAMBAT',
    ),
    DropdownOption(
      label: 'Body Ada Rembesan Dan Potensi Menetes Cepat',
      value: 'BODY ADA REMBESAN DAN POTENSI MENETES CEPAT',
    ),
  ];

  static const List<DropdownOption> trafoPsKondisiFisik = [
    DropdownOption(label: 'Mulus Bersih', value: 'MULUS BERSIH'),
    DropdownOption(label: 'Mulus Kotor', value: 'MULUS KOTOR'),
    DropdownOption(label: 'Cacat Sirip Minor', value: 'CACAT SIRIP MINOR'),
    DropdownOption(label: 'Cacat Sirip Major', value: 'CACAT SIRIP MAJOR'),
    DropdownOption(label: 'Bengkak', value: 'BENGKAK'),
  ];

  static const List<DropdownOption> trafoPsKondisiRumah = [
    DropdownOption(label: 'Ada Dan Baik', value: 'ADA DAN BAIK'),
    DropdownOption(label: 'Tidak Ada Atap', value: 'TIDAK ADA ATAP'),
    DropdownOption(
      label: 'Pondasi Miring/Tidak Ada Pondasi',
      value: 'PONDASI MIRING/TIDAK ADA PONDASI',
    ),
    DropdownOption(label: 'Ada Potensi Binatang', value: 'ADA POTENSI BINATANG'),
  ];

  // ===========================================================================
  // IL1 SIPIL
  // ===========================================================================
  static const List<DropdownOption> sipilBaikTidak = [
    DropdownOption(label: 'Baik', value: 'BAIK'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilJenisLampu = [
    DropdownOption(label: 'TL', value: 'TL'),
    DropdownOption(label: 'LED', value: 'LED'),
  ];

  static const List<DropdownOption> sipilKondisiRuangan = [
    DropdownOption(label: 'Panas', value: 'PANAS'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilKondisiAtap = [
    DropdownOption(label: 'Bocor', value: 'BOCOR'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilYaTidak = [
    DropdownOption(label: 'Ya', value: 'YA'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilBocorTidak = [
    DropdownOption(label: 'Bocor', value: 'BOCOR'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilBerfungsiTidak = [
    DropdownOption(label: 'Berfungsi', value: 'BERFUNGSI'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilAdaTidak = [
    DropdownOption(label: 'Ada', value: 'ADA'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];

  static const List<DropdownOption> sipilBersihTidak = [
    DropdownOption(label: 'Bersih', value: 'BERSIH'),
    DropdownOption(label: 'Tidak', value: 'TIDAK'),
  ];
}
