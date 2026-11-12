import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_realisasi_model.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/beban_penyulang_utils.dart';

void main() {
  group('Beban Penyulang Logic & Manuver Tests', () {
    test('toTimeIndex calculates exact chronological index', () {
      final index1 = toTimeIndex(2026, 11, 9, 8);
      final index2 = toTimeIndex(2026, 11, 9, 9);
      expect(index1, equals(20261109008));
      expect(index2, equals(20261109009));
      expect(index1 < index2, isTrue);
    });

    test('calculateManuvers marks periods within ongoing manuver as MANUVER', () {
      final periods = [
        const PenyulangPeriodModel(periode: 7, tanggal: 9, bulan: 11, tahun: 2026),
        const PenyulangPeriodModel(periode: 8, tanggal: 9, bulan: 11, tahun: 2026),
        const PenyulangPeriodModel(periode: 9, tanggal: 9, bulan: 11, tahun: 2026),
      ];

      // Manuver OPEN pada jam 7 tanpa CLOSE
      final manuver = [
        const PenyulangManuverItemModel(
          id: 1,
          periode: 7,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          status: 'OPEN',
        ),
      ];

      final results = calculateManuvers(periods, manuver);
      expect(results.length, equals(3));
      // Periode 7 dan 8 dalam status MANUVER
      expect(results[0]['status'], equals('MANUVER'));
      expect(results[1]['status'], equals('MANUVER'));
    });

    test('calculateManuvers ends range on CLOSE', () {
      final periods = [
        const PenyulangPeriodModel(periode: 6, tanggal: 9, bulan: 11, tahun: 2026),
        const PenyulangPeriodModel(periode: 7, tanggal: 9, bulan: 11, tahun: 2026),
        const PenyulangPeriodModel(periode: 8, tanggal: 9, bulan: 11, tahun: 2026),
        const PenyulangPeriodModel(periode: 9, tanggal: 9, bulan: 11, tahun: 2026),
      ];

      // OPEN jam 7, CLOSE jam 8
      final manuver = [
        const PenyulangManuverItemModel(
          id: 1,
          periode: 7,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          status: 'OPEN',
        ),
        const PenyulangManuverItemModel(
          id: 2,
          periode: 8,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          status: 'CLOSE',
        ),
      ];

      final results = calculateManuvers(periods, manuver);
      // Periode 6: sebelum manuver -> null
      expect(results[0]['status'], isNull);
      // Periode 7: in manuver -> MANUVER
      expect(results[1]['status'], equals('MANUVER'));
      // Periode 8 (CLOSE reached): outside manuver range -> null
      expect(results[2]['status'], isNull);
      expect(results[3]['status'], isNull);
    });

    test('mapPenyulangPeriods computes colors and statuses correctly', () {
      const penyulang = PenyulangModel(
        id: 10,
        nama: 'Penyulang Cempaka',
        statusCB: 'ON',
        iMax: 600,
        rel: '1',
        garduIndukId: 1,
        garduIndukNama: 'GI Gandul',
        periods: [
          PenyulangPeriodModel(periode: 7, tanggal: 9, bulan: 11, tahun: 2026),
          PenyulangPeriodModel(periode: 8, tanggal: 9, bulan: 11, tahun: 2026),
          PenyulangPeriodModel(periode: 9, tanggal: 9, bulan: 11, tahun: 2026),
          PenyulangPeriodModel(periode: 10, tanggal: 9, bulan: 11, tahun: 2026),
        ],
        beban: [
          PenyulangBebanItemModel(
            id: 1,
            periode: 7,
            beban: 120,
            status: 'ON TIME',
            tanggal: 9,
            bulan: 11,
            tahun: 2026,
          ),
          PenyulangBebanItemModel(
            id: 2,
            periode: 8,
            beban: 140,
            status: 'PERHATIAN',
            tanggal: 9,
            bulan: 11,
            tahun: 2026,
          ),
        ],
      );

      final localDrafts = [
        {
          'id': 101,
          'nama': 'Penyulang Cempaka-GI Gandul',
          'data': {
            'id': 10,
            'garduIndukId': 1,
            'periode': 9,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
            'beban': '150',
          },
        },
      ];

      final mapped = mapPenyulangPeriods(item: penyulang, localDrafts: localDrafts);

      expect(mapped.length, equals(4));

      // Periode 7: ON TIME -> Hijau
      expect(mapped[0].isDone, isTrue);
      expect(mapped[0].color, equals(const Color(0xFF22C55E)));

      // Periode 8: PERHATIAN -> Kuning
      expect(mapped[1].isDone, isTrue);
      expect(mapped[1].color, equals(const Color(0xFFEAB308)));

      // Periode 9: Draft lokal tersimpan -> Putih (dengan border oranye)
      expect(mapped[2].isDone, isFalse);
      expect(mapped[2].draft, isTrue);
      expect(mapped[2].color, equals(Colors.white));

      // Periode 10: Belum diisi -> Abu-abu
      expect(mapped[3].isDone, isFalse);
      expect(mapped[3].draft, isFalse);
      expect(mapped[3].color, equals(const Color(0xFF6B7280)));
    });

    test('parseBebanPenyulangDrafts detects duplicate and returns valid drafts', () {
      const penyulang = PenyulangModel(
        id: 10,
        nama: 'Penyulang Cempaka',
        statusCB: 'ON',
        iMax: 600,
        rel: '1',
        garduIndukId: 1,
        garduIndukNama: 'GI Gandul',
        beban: [
          PenyulangBebanItemModel(
            id: 1,
            periode: 7,
            beban: 120,
            status: 'ON TIME',
            tanggal: 9,
            bulan: 11,
            tahun: 2026,
          ),
        ],
      );

      final localDrafts = [
        // Duplicate draft (periode 7 sudah tersimpan di server)
        {
          'id': 101,
          'nama': 'Penyulang Cempaka-GI Gandul',
          'data': {
            'id': 10,
            'garduIndukId': 1,
            'periode': 7,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
            'beban': '120',
            'foto': {'uri': '/path/foto.jpg'},
            'durasi': 1.5,
          },
        },
        // Valid draft siap upload (periode 8)
        {
          'id': 102,
          'nama': 'Penyulang Cempaka-GI Gandul',
          'data': {
            'id': 10,
            'garduIndukId': 1,
            'periode': 8,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
            'beban': '135',
            'foto': {'uri': '/path/foto8.jpg'},
            'durasi': 2.0,
          },
        },
      ];

      final result = parseBebanPenyulangDrafts(
        localDrafts: localDrafts,
        garduIndukId: 1,
        penyulangList: [penyulang],
      );

      expect(result.duplicates, contains(101));
      expect(result.parsed.length, equals(1));
      expect(result.parsed.first['draftId'], equals(102));
      expect(result.parsed.first['beban'], equals(135.0));
      expect(result.parsed.first['penyulangId'], equals(10));
    });
  });
}
