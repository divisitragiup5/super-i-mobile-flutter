import '../../data/models/opgi_realisasi_model.dart';

/// Daftar jenis stand kWh harian berdasarkan kelompok
const Map<String, List<String>> kJenisKelompokKwh = {
  'FEEDER': ['H', 'L1', 'L2'],
  'TRAFO PS': ['H', 'L1', 'L2'],
  'TRAFO TRANSAKSI': ['H', 'L1', 'L2', 'KVARH'],
  'TRAFO PEMBANDING': ['H', 'L1', 'L2', 'KVARH'],
};

/// Memeriksa apakah satu item stand sudah lengkap (ada stand dan ada fotoStand)
bool isItemComplete(dynamic item) {
  if (item == null || item is! Map) return false;
  final stand = item['stand'];
  final foto = item['fotoStand'];

  final hasStand = stand != null && stand.toString().trim().isNotEmpty;
  bool hasFoto = false;
  if (foto is Map) {
    final uri = foto['uri']?.toString();
    hasFoto = uri != null && uri.isNotEmpty;
  } else if (foto is String) {
    hasFoto = foto.isNotEmpty;
  }

  return hasStand && hasFoto;
}

/// Memeriksa apakah format desimal stand valid (tidak mengandung koma dan bisa diparse ke double)
bool isStandValidDecimal(List<dynamic> items) {
  for (final item in items) {
    if (item is! Map) continue;
    final stand = item['stand'];
    if (stand == null || stand.toString().trim().isEmpty) continue;
    final str = stand.toString().trim();
    if (str.contains(',')) return false;
    if (double.tryParse(str) == null) return false;
  }
  return true;
}

class ParsedKwhHarianDraftResult {
  final List<Map<String, dynamic>> parsed;
  final List<int> duplicates;

  const ParsedKwhHarianDraftResult({
    required this.parsed,
    required this.duplicates,
  });
}

/// Parsing draft kWh harian dengan memfilter data duplikat dan memformat DTO bersih
ParsedKwhHarianDraftResult parseKwhHarianDrafts({
  required List<Map<String, dynamic>> localDrafts,
  required int garduIndukId,
  required List<KwhHarianModel> mappedData,
}) {
  final existingKeySet = <String>{};
  for (final item in mappedData) {
    final isDone = item.isDone || item.kwhHarian.isNotEmpty;
    if (isDone) {
      existingKeySet.add('${item.nama}-${item.garduIndukNama}');
      existingKeySet.add('${item.nama}-${item.kelompok}-${item.garduIndukNama}');
    }
  }

  final parsed = <Map<String, dynamic>>[];
  final duplicates = <int>[];

  for (final draft in localDrafts) {
    final draftRowId = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}');
    final namaDraft = draft['nama']?.toString() ?? '';
    final rawData = draft['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{});

    final rawItems = data['data'];
    if (rawItems is! List || rawItems.isEmpty) continue;

    final allValid = rawItems.every(isItemComplete);
    final objectId = int.tryParse('${data['objectId']}') ?? 0;
    final durasiNum = (num.tryParse('${data['durasi']}') ?? 0.0).toDouble();
    final giId = int.tryParse('${data['garduIndukId']}') ?? 0;
    final type = data['type']?.toString() ?? 'PENYULANG';
    final kelompok = data['kelompok']?.toString() ?? 'FEEDER';

    if (objectId <= 0 || !allValid || giId != garduIndukId) {
      continue;
    }

    if (existingKeySet.contains(namaDraft)) {
      if (draftRowId != null) duplicates.add(draftRowId);
      continue;
    }

    final filesWithJenis = <Map<String, dynamic>>[];
    final dtoList = <Map<String, dynamic>>[];

    for (final rawStand in rawItems) {
      if (rawStand is! Map) continue;
      final jenis = rawStand['jenis']?.toString() ?? '';
      final standNum = double.tryParse('${rawStand['stand']}') ?? 0.0;
      final keterangan = rawStand['keterangan']?.toString();

      final rawFoto = rawStand['fotoStand'];
      String? fotoUri;
      Map<String, dynamic> fotoMeta = {};
      if (rawFoto is Map) {
        fotoUri = rawFoto['uri']?.toString();
        fotoMeta = Map<String, dynamic>.from(rawFoto)..remove('uri');
      } else if (rawFoto is String) {
        fotoUri = rawFoto;
      }

      if (fotoUri == null || fotoUri.isEmpty) continue;

      filesWithJenis.add({
        'jenis': jenis,
        'file': fotoUri,
      });

      dtoList.add({
        'jenis': jenis,
        'stand': standNum,
        if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
        'durasi': durasiNum,
        if (fotoMeta.isNotEmpty)
          'fotoStand': {
            ...fotoMeta,
            if (fotoMeta['date'] != null)
              'date': DateTime.tryParse(fotoMeta['date'].toString())?.toIso8601String() ??
                  fotoMeta['date'].toString(),
          },
      });
    }

    if (filesWithJenis.isEmpty || filesWithJenis.length != rawItems.length) {
      continue;
    }

    final dtoData = <String, dynamic>{
      'objectId': objectId,
      'type': type,
      'kelompok': kelompok,
      'timezone': 'Asia/Jakarta',
      'data': dtoList,
    };

    parsed.add({
      'draftId': draftRowId,
      'filesWithJenis': filesWithJenis,
      'data': dtoData,
    });
  }

  return ParsedKwhHarianDraftResult(
    parsed: parsed,
    duplicates: duplicates,
  );
}
