import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/utils/color_parser.dart';
import 'package:super_i_mobile/features/home/data/models/sutm_inspeksi_score_model.dart';
import 'package:super_i_mobile/features/home/data/models/sutm_pemeliharaan_score_model.dart';

void main() {
  group('Home Summary Models & ColorParser Test', () {
    test('ColorParser should parse hex and rgb strings correctly', () {
      final hexColor = ColorParser.parse('#22c55e');
      expect(hexColor, const Color(0xFF22C55E));

      final rgbColor = ColorParser.parse('rgb(16, 185, 129)');
      expect(rgbColor, const Color.fromARGB(255, 16, 185, 129));

      final fallbackColor = ColorParser.parse(null);
      expect(fallbackColor, const Color(0xFF10B981));
    });

    test('SutmInspeksiScoreModel parses JSON correctly', () {
      final json = {
        'date': '2026-10-30',
        'targetInspeksi': 10,
        'realisasiInspeksi': 8,
        'pencapaianInspeksi': 80.0,
        'pointPencapaianInspeksi': 80.0,
        'pencapaianInspeksiConfig': {
          'id': 1,
          'category': 'Pencapaian',
          'item': 'AMAN',
          'color': '#22c55e',
        },
        'durasiInspeksi': 120.0,
        'pointDurasiInspeksi': 90.0,
        'durasiInspeksiConfig': {
          'id': 2,
          'category': 'Durasi',
          'item': 'AMAN',
          'color': '#3b82f6',
        },
        'performa': 85.0,
        'performaConfig': {
          'id': 3,
          'category': 'Performa',
          'item': 'AMAN',
          'color': '#10b981',
        },
      };

      final model = SutmInspeksiScoreModel.fromJson(json);
      expect(model.targetInspeksi, 10);
      expect(model.realisasiInspeksi, 8);
      expect(model.performa, 85.0);
      expect(model.performaConfig?.category, 'Performa');
    });

    test('SutmPemeliharaanScoreModel parses JSON correctly', () {
      final json = {
        'date': '2026-10-30',
        'targetPemeliharaan': 12,
        'realisasiPemeliharaan': 10,
        'pencapaianPemeliharaan': 83.33,
        'pointPencapaianPemeliharaan': 83.33,
        'volumeRencana': 15,
        'volumeTerlaksana': 12,
        'volumeKendala': 3,
        'penyelesaianRencana': 80.0,
        'pointPenyelesaianRencana': 80.0,
        'durasiPemeliharaan': 120,
        'performa': 88.0,
        'performaConfig': {
          'category': 'Sangat Baik',
          'color': '#10b981',
        },
      };

      final model = SutmPemeliharaanScoreModel.fromJson(json);
      expect(model.targetPemeliharaan, 12);
      expect(model.realisasiPemeliharaan, 10);
      expect(model.volumeKendala, 3);
      expect(model.performaConfig?.category, 'Sangat Baik');
    });
  });

  group('Face Anti-Spoof Softmax & Logic Verification', () {
    test('Softmax correctly detects screen attack from logits', () {
      final logits = [-3.0229115, -4.67003, 7.6966195];

      final maxLogit = [logits[0], logits[1], logits[2]].reduce((a, b) => a > b ? a : b);
      final exp0 = math.exp(logits[0] - maxLogit);
      final exp1 = math.exp(logits[1] - maxLogit);
      final exp2 = math.exp(logits[2] - maxLogit);
      final sumExp = exp0 + exp1 + exp2;

      final probReal = exp1 / sumExp;
      final probScreen = exp2 / sumExp;

      expect(probScreen, greaterThan(0.99));
      expect(probReal, lessThan(0.01));
      expect(probReal >= 0.40, isFalse);
    });

    test('Softmax correctly accepts real face from logits', () {
      final logits = [-0.76717734, 1.4499426, -0.6842941];

      final maxLogit = [logits[0], logits[1], logits[2]].reduce((a, b) => a > b ? a : b);
      final exp0 = math.exp(logits[0] - maxLogit);
      final exp1 = math.exp(logits[1] - maxLogit);
      final exp2 = math.exp(logits[2] - maxLogit);
      final sumExp = exp0 + exp1 + exp2;

      final probReal = exp1 / sumExp;
      final probScreen = exp2 / sumExp;

      expect(probReal, greaterThan(0.70));
      expect(probScreen, lessThan(0.20));
      expect(probReal >= 0.40, isTrue);
    });
  });
}
