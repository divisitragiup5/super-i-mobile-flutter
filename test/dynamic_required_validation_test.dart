import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/widgets/app_input_label.dart';
import 'package:super_i_mobile/core/widgets/app_toggle_bar.dart';

void main() {
  group('AppInputLabel Widget Tests', () {
    testWidgets('Renders label without asterisk when isRequired is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInputLabel('Catatan Anomali', isRequired: false),
          ),
        ),
      );

      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      expect(richText.text.toPlainText(), 'Catatan Anomali');
    });

    testWidgets('Renders label with bold red asterisk when isRequired is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInputLabel('Nama Pekerjaan', isRequired: true),
          ),
        ),
      );

      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      expect(richText.text.toPlainText(), 'Nama Pekerjaan *');
    });
  });

  group('AppToggleBar Widget Tests', () {
    testWidgets('Renders items and switches selected value on tap', (tester) async {
      String selected = 'TIDAK';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppToggleBar<String>(
                  label: 'KENDALA',
                  isRequired: true,
                  selectedValue: selected,
                  items: const [
                    ToggleItem(label: 'TIDAK', value: 'TIDAK'),
                    ToggleItem(label: 'KENDALA', value: 'KENDALA'),
                  ],
                  onValueChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('KENDALA *'), findsOneWidget);
      expect(find.text('TIDAK'), findsOneWidget);
      expect(find.text('KENDALA'), findsOneWidget);

      await tester.tap(find.text('KENDALA'));
      await tester.pumpAndSettle();

      expect(selected, 'KENDALA');
    });
  });

  group('Line Walker Form Dynamic Validation Logic Tests', () {
    test('Waterpass: minimal one axis complete (both hasil & photo)', () {
      bool isAxisComplete(String hasil, bool hasFoto) {
        return hasil.trim().isNotEmpty && hasFoto;
      }

      bool hasAnyCompleteAxis({
        required String hasilX,
        required bool hasFotoX,
        required String hasilY,
        required bool hasFotoY,
        required String hasilZ,
        required bool hasFotoZ,
      }) {
        return isAxisComplete(hasilX, hasFotoX) ||
            isAxisComplete(hasilY, hasFotoY) ||
            isAxisComplete(hasilZ, hasFotoZ);
      }

      // Initial state: none filled -> invalid
      expect(hasAnyCompleteAxis(
        hasilX: '', hasFotoX: false,
        hasilY: '', hasFotoY: false,
        hasilZ: '', hasFotoZ: false,
      ), isFalse);

      // Partial fill: value filled but photo missing -> invalid
      expect(hasAnyCompleteAxis(
        hasilX: '0.05', hasFotoX: false,
        hasilY: '', hasFotoY: false,
        hasilZ: '', hasFotoZ: false,
      ), isFalse);

      // Complete fill on one axis -> valid
      expect(hasAnyCompleteAxis(
        hasilX: '0.05', hasFotoX: true,
        hasilY: '', hasFotoY: false,
        hasilZ: '', hasFotoZ: false,
      ), isTrue);
    });

    test('Pembumian: dynamic requirement on legs and anomaly', () {
      bool isLegComplete(String hasil, bool hasPict, bool hasStatusPict) {
        return hasil.trim().isNotEmpty && hasPict && hasStatusPict;
      }

      bool isLegAnyEntered(String hasil, bool hasPict, bool hasStatusPict) {
        return hasil.trim().isNotEmpty || hasPict || hasStatusPict;
      }

      // If user started typing leg A value, all leg A fields become required
      expect(isLegAnyEntered('5.2', false, false), isTrue);
      // But it is not complete until both photos are attached
      expect(isLegComplete('5.2', false, false), isFalse);
      expect(isLegComplete('5.2', true, true), isTrue);

      // Kendala toggle logic: When 'KENDALA', all 8 legs are bypassed and omitted
      bool isLegsRequirementSatisfied({
        required String kendala,
        required List<Map<String, dynamic>> legs,
      }) {
        if (kendala == 'KENDALA') {
          return true; // Not required when kendala is toggled to KENDALA
        }
        return legs.any((leg) =>
            leg['hasil']?.toString().trim().isNotEmpty == true &&
            leg['hasFoto'] == true &&
            leg['hasFotoStatus'] == true);
      }

      expect(isLegsRequirementSatisfied(kendala: 'KENDALA', legs: []), isTrue);
      expect(isLegsRequirementSatisfied(kendala: 'TIDAK', legs: []), isFalse);
      expect(
        isLegsRequirementSatisfied(
          kendala: 'TIDAK',
          legs: [{'hasil': '5.2', 'hasFoto': true, 'hasFotoStatus': true}],
        ),
        isTrue,
      );

      // Anomali: mutual dependency
      bool isAnomaliValid(String catatan, bool hasFoto) {
        final hasCatatan = catatan.trim().isNotEmpty;
        if (hasFoto && !hasCatatan) return false;
        if (hasCatatan && !hasFoto) return false;
        return true;
      }

      expect(isAnomaliValid('', false), isTrue); // Empty is fine (optional)
      expect(isAnomaliValid('Karat pada kawat', false), isFalse); // Catatan without foto -> invalid
      expect(isAnomaliValid('', true), isFalse); // Foto without catatan -> invalid
      expect(isAnomaliValid('Karat pada kawat', true), isTrue); // Both provided -> valid
    });

    test('PPL & Kegiatan Sosial: Team Leader GI signature mutual dependency', () {
      bool isTlGiValid(String nama, bool hasTtd) {
        final hasNama = nama.trim().isNotEmpty;
        if (hasTtd && !hasNama) return false;
        if (!hasTtd && hasNama) return false;
        return true;
      }

      expect(isTlGiValid('', false), isTrue); // Optional when both empty
      expect(isTlGiValid('Budi Santoso', false), isFalse); // Name filled but no TTD -> invalid
      expect(isTlGiValid('', true), isFalse); // TTD signed but no name -> invalid
      expect(isTlGiValid('Budi Santoso', true), isTrue); // Both filled -> valid
    });

    test('Kegiatan Sosial: Jumlah Temuan conditionally required', () {
      bool isTemuanValid(String temuan, String jumlahTemuan) {
        if (temuan == 'ADA TEMUAN') {
          return jumlahTemuan.trim().isNotEmpty;
        }
        return true;
      }

      expect(isTemuanValid('TIDAK ADA TEMUAN', ''), isTrue);
      expect(isTemuanValid('ADA TEMUAN', ''), isFalse);
      expect(isTemuanValid('ADA TEMUAN', '3'), isTrue);
    });
  });
}
