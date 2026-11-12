import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/theme/app_theme.dart';
import 'package:super_i_mobile/core/widgets/app_video_player.dart';
import 'package:super_i_mobile/core/widgets/field_video_input.dart';

void main() {
  group('AppVideoPlayer Widget Tests', () {
    testWidgets('renders fallback error gracefully if video file does not exist',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppVideoPlayer(
              videoFile: null,
              videoUrl: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat video'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_off_outlined), findsOneWidget);
    });

    testWidgets('renders fallback error if URL is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppVideoPlayer(
              videoUrl: '',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat video'), findsOneWidget);
    });
  });

  group('FieldVideoInput Widget Tests', () {
    testWidgets('renders placeholder button when no video is selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FieldVideoInput(
              label: 'Vidio Bukti',
              placeholder: 'Ambil video (Maks 10 Detik)',
              videoFile: null,
              onChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Vidio Bukti'), findsOneWidget);
      expect(find.text('Ambil video (Maks 10 Detik)'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
      expect(find.text('Pilih dari Galeri'), findsNothing);
    });

    testWidgets('renders Hapus Video button when video is present and triggers onChange(null)',
        (tester) async {
      File? currentVideo = File('/dummy/path/video.mp4');
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FieldVideoInput(
                  label: 'Vidio Bukti',
                  videoFile: currentVideo,
                  onChange: (f) {
                    setState(() {
                      currentVideo = f;
                      deleted = true;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // When file is passed, it should show 'Hapus Video' button
      expect(find.text('Hapus Video'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Tap Hapus Video
      await tester.tap(find.text('Hapus Video'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
      expect(currentVideo, isNull);
      expect(find.text('Ambil video (Maks 10 Detik)'), findsOneWidget);
    });

    testWidgets('renders errorText when validation fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FieldVideoInput(
              label: 'Vidio Bukti',
              videoFile: null,
              errorText: 'Video bukti wajib direkam',
              onChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Video bukti wajib direkam'), findsOneWidget);
    });
  });
}
