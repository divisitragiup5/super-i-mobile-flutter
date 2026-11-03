import 'dart:io';

class LegInputModel {
  final double? hasil;
  final String? status;
  final File? pict;
  final File? statusPict;

  LegInputModel({
    this.hasil,
    this.status,
    this.pict,
    this.statusPict,
  });

  Map<String, dynamic> toJsonDraft() {
    return {
      'hasil': hasil,
      'status': status,
      'pictPath': pict?.path,
      'statusPictPath': statusPict?.path,
    };
  }

  factory LegInputModel.fromJsonDraft(Map<String, dynamic> json) {
    return LegInputModel(
      hasil: (json['hasil'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      pict: json['pictPath'] != null ? File(json['pictPath']) : null,
      statusPict: json['statusPictPath'] != null ? File(json['statusPictPath']) : null,
    );
  }
}

class PembumianInputModel {
  final int towerId;
  final String? namaTower;
  final String kendala; // 'TIDAK' atau lainnya
  final File? fotoSebelum;
  final File? fotoSetelah;
  final LegInputModel? legA;
  final LegInputModel? legB;
  final LegInputModel? legC;
  final LegInputModel? legD;
  final LegInputModel? igsw;
  final LegInputModel? groundingLangsung;
  final LegInputModel? bersama;
  final LegInputModel? mdg;
  final String? catatanAnomali;
  final File? fotoAnomali;

  PembumianInputModel({
    required this.towerId,
    this.namaTower,
    this.kendala = 'TIDAK',
    this.fotoSebelum,
    this.fotoSetelah,
    this.legA,
    this.legB,
    this.legC,
    this.legD,
    this.igsw,
    this.groundingLangsung,
    this.bersama,
    this.mdg,
    this.catatanAnomali,
    this.fotoAnomali,
  });

  Map<String, dynamic> toJsonDraft() {
    return {
      'towerId': towerId,
      'namaTower': namaTower,
      'kendala': kendala,
      'fotoSebelumPath': fotoSebelum?.path,
      'fotoSetelahPath': fotoSetelah?.path,
      'legA': legA?.toJsonDraft(),
      'legB': legB?.toJsonDraft(),
      'legC': legC?.toJsonDraft(),
      'legD': legD?.toJsonDraft(),
      'igsw': igsw?.toJsonDraft(),
      'groundingLangsung': groundingLangsung?.toJsonDraft(),
      'bersama': bersama?.toJsonDraft(),
      'mdg': mdg?.toJsonDraft(),
      'catatanAnomali': catatanAnomali,
      'fotoAnomaliPath': fotoAnomali?.path,
    };
  }

  factory PembumianInputModel.fromJsonDraft(Map<String, dynamic> json) {
    return PembumianInputModel(
      towerId: json['towerId'] as int? ?? 0,
      namaTower: json['namaTower'] as String?,
      kendala: json['kendala']?.toString() ?? 'TIDAK',
      fotoSebelum: json['fotoSebelumPath'] != null ? File(json['fotoSebelumPath']) : null,
      fotoSetelah: json['fotoSetelahPath'] != null ? File(json['fotoSetelahPath']) : null,
      legA: json['legA'] != null ? LegInputModel.fromJsonDraft(json['legA']) : null,
      legB: json['legB'] != null ? LegInputModel.fromJsonDraft(json['legB']) : null,
      legC: json['legC'] != null ? LegInputModel.fromJsonDraft(json['legC']) : null,
      legD: json['legD'] != null ? LegInputModel.fromJsonDraft(json['legD']) : null,
      igsw: json['igsw'] != null ? LegInputModel.fromJsonDraft(json['igsw']) : null,
      groundingLangsung: json['groundingLangsung'] != null ? LegInputModel.fromJsonDraft(json['groundingLangsung']) : null,
      bersama: json['bersama'] != null ? LegInputModel.fromJsonDraft(json['bersama']) : null,
      mdg: json['mdg'] != null ? LegInputModel.fromJsonDraft(json['mdg']) : null,
      catatanAnomali: json['catatanAnomali']?.toString(),
      fotoAnomali: json['fotoAnomaliPath'] != null ? File(json['fotoAnomaliPath']) : null,
    );
  }
}

class PembumianHistoryItemModel {
  final int id;
  final String? namaTower;
  final String? createdAt;
  final String? kendala;
  final double? nilaiRataRata;

  PembumianHistoryItemModel({
    required this.id,
    this.namaTower,
    this.createdAt,
    this.kendala,
    this.nilaiRataRata,
  });

  factory PembumianHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PembumianHistoryItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      namaTower: json['tower'] is Map ? json['tower']['nama']?.toString() : null,
      createdAt: json['createdAt']?.toString(),
      kendala: json['kendala']?.toString(),
      nilaiRataRata: (json['nilaiRataRata'] as num?)?.toDouble(),
    );
  }
}
