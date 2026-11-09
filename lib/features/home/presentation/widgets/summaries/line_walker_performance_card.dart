import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circular_gauge.dart';
import '../../../../../core/widgets/month_year_picker_dialog.dart';
import '../../../../line_walker/data/models/line_walker_performance_model.dart';
import '../../cubit/line_walker_performance_cubit.dart';
import '../performance_trend_chart_sheet.dart';

class LineWalkerPerformanceCard extends StatefulWidget {
  const LineWalkerPerformanceCard({super.key});

  @override
  State<LineWalkerPerformanceCard> createState() =>
      _LineWalkerPerformanceCardState();
}

class _LineWalkerPerformanceCardState extends State<LineWalkerPerformanceCard> {
  bool _showMore = false;

  static const List<String> _bulanList = [
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];

  static const List<int> _mingguList = [1, 2, 3, 4, 5];

  String _capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showFilterModal(BuildContext context, LineWalkerPerformanceLoaded? loadedState) {
    final cubit = context.read<LineWalkerPerformanceCubit>();

    int? tempMinggu = loadedState?.filterMinggu ?? loadedState?.performance?.minggu;
    String? tempBulan = loadedState?.filterBulan ?? loadedState?.performance?.bulan;
    int? tempTahun = loadedState?.filterTahun ?? loadedState?.performance?.tahun ?? DateTime.now().year;

    // Normalisasi tempBulan ke uppercase jika ada
    if (tempBulan != null) {
      tempBulan = tempBulan.toUpperCase();
      if (!_bulanList.contains(tempBulan)) {
        tempBulan = _bulanList[DateTime.now().month - 1];
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Kinerja Line Walker',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(modalCtx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // 1. Pilihan Minggu
                  const Text(
                    'Minggu ke-',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    initialValue: tempMinggu,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    hint: const Text('Pilih Minggu'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Semua Minggu'),
                      ),
                      ..._mingguList.map(
                        (m) => DropdownMenuItem<int?>(
                          value: m,
                          child: Text('Minggu $m'),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() => tempMinggu = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Pilihan Periode Bulan & Tahun (Month Picker Modern)
                  const Text(
                    'Periode Bulan & Tahun',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      int initMonth = DateTime.now().month;
                      if (tempBulan != null) {
                        final idx = _bulanList.indexOf(tempBulan!.toUpperCase());
                        if (idx != -1) initMonth = idx + 1;
                      }
                      final initYear = tempTahun ?? DateTime.now().year;

                      final picked = await MonthYearPickerDialog.show(
                        modalCtx,
                        initialMonth: initMonth,
                        initialYear: initYear,
                        useRootNavigator: true,
                      );

                      if (picked != null) {
                        setModalState(() {
                          tempBulan = _bulanList[picked.month - 1];
                          tempTahun = picked.year;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (tempBulan != null || tempTahun != null)
                              ? AppColors.primary
                              : AppColors.border,
                          width: (tempBulan != null || tempTahun != null) ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: (tempBulan != null || tempTahun != null)
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              (tempBulan != null && tempTahun != null)
                                  ? '${_capitalize(tempBulan)} $tempTahun'
                                  : (tempBulan != null)
                                      ? _capitalize(tempBulan)
                                      : (tempTahun != null)
                                          ? '$tempTahun'
                                          : 'Pilih bulan & tahun...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: (tempBulan != null || tempTahun != null)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: (tempBulan != null || tempTahun != null)
                                    ? AppColors.textPrimary
                                    : AppColors.textDisabled,
                              ),
                            ),
                          ),
                          if (tempBulan != null || tempTahun != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setModalState(() {
                                  tempBulan = null;
                                  tempTahun = null;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.cancel,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Aksi (Reset & Cari)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: () {
                            Navigator.pop(modalCtx);
                            cubit.resetFilter();
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(modalCtx);
                            cubit.fetchPerformance(
                              minggu: tempMinggu,
                              bulan: tempBulan,
                              tahun: tempTahun,
                            );
                          },
                          child: const Text(
                            'Cari',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    LineWalkerPerformanceLoaded? loadedState,
  ) {
    final isFiltered = loadedState?.isFiltered ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('[LineWalkerPerformanceCard] Filter button tapped!');
        _showFilterModal(context, loadedState);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFiltered ? AppColors.primary : AppColors.border,
            width: isFiltered ? 1.5 : 1.0,
          ),
          color: isFiltered
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 14,
              color: isFiltered ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              isFiltered ? 'Difilter' : 'Filter',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isFiltered ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTrendChart(
    BuildContext context, {
    required String title,
    required String trendKey,
    required LineWalkerPerformanceModel? data,
  }) {
    if (data == null) return;
    final points = data.getTrendPoints(trendKey);
    PerformanceTrendChartSheet.show(
      context,
      title: title,
      points: points,
    );
  }

  /// Kartu Gelap Transparan Persis perform-item.tsx (rgba(0,0,0,0.45))
  Widget _buildPerformItem({
    required BuildContext context,
    required String title,
    required int target,
    required int realisasi,
    required double progress,
    required String trendKey,
    required LineWalkerPerformanceModel data,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openTrendChart(
          context,
          title: title,
          trendKey: trendKey,
          data: data,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.45),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.insights,
                    size: 13,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CircularGauge(
                progress: progress,
                radius: 46,
                strokeWidth: 10,
                color: AppColors.secondary,
                showPercent: true,
                textColor: Colors.white,
                onTap: () => _openTrendChart(
                  context,
                  title: title,
                  trendKey: trendKey,
                  data: data,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '(T) $target / $realisasi (R)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LineWalkerPerformanceCubit, LineWalkerPerformanceState>(
      builder: (context, state) {
        if (state is LineWalkerPerformanceLoading) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is LineWalkerPerformanceError) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<LineWalkerPerformanceCubit>()
                          .fetchPerformance(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Coba Lagi'),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterButton(context, null),
                  ],
                ),
              ],
            ),
          );
        }

        LineWalkerPerformanceModel? data;
        LineWalkerPerformanceLoaded? loadedState;
        if (state is LineWalkerPerformanceLoaded) {
          data = state.performance;
          loadedState = state;
        }

        // Tentukan Judul Berdasarkan Filter atau Data API
        String title = 'Penyelesaian Tugas';
        if (loadedState != null && loadedState.isFiltered) {
          final parts = <String>[];
          if (loadedState.filterMinggu != null) {
            parts.add('Minggu ${loadedState.filterMinggu}');
          }
          if (loadedState.filterBulan != null) {
            parts.add(_capitalize(loadedState.filterBulan));
          }
          if (loadedState.filterTahun != null) {
            parts.add('${loadedState.filterTahun}');
          }
          title = 'Penyelesaian Tugas ${parts.join(' ')}';
        } else if (data != null && data.minggu != null) {
          title =
              'Penyelesaian Tugas Minggu ${data.minggu} ${_capitalize(data.bulan)} ${data.tahun ?? ''}';
        }

        // Jika data kosong / belum ada penilaian (seperti di React Native)
        if (data == null) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 26,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildFilterButton(context, loadedState),
                  ],
                ),
              ],
            ),
          );
        }

        final score = data.score;
        final rawCat = data.kategoriPerformaTenagaKerja;

        // Tentukan Tag Status
        String statusLabel = 'BAIK';
        Color statusColor = AppColors.success;
        IconData statusIcon = Icons.check_circle;

        if (rawCat == 'mid-perform') {
          statusLabel = 'WASPADA';
          statusColor = AppColors.warning;
          statusIcon = Icons.info;
        } else if (rawCat != 'top-perform') {
          statusLabel = 'KURANG';
          statusColor = AppColors.danger;
          statusIcon = Icons.cancel;
        }

        final penilaian = data.penilaian.isNotEmpty
            ? data.penilaian
            : ['PENCAPAIAN', 'COC', 'ABSENSI', 'DURASI'];

        return Column(
          children: [
            // ─── KARTU UTAMA (rgba(255,255,255,0.82)) ───
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Judul & Periode
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Badge (BAIK / WASPADA / KURANG)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Circular Progress Gauge Utama (Radius 70, Stroke 14)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openTrendChart(
                      context,
                      title: 'Performa Tenaga Kerja',
                      trendKey: 'score',
                      data: data,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          CircularGauge(
                            progress: score,
                            radius: 70,
                            strokeWidth: 14,
                            color: AppColors.primaryLight,
                            centerLabel: 'Performa',
                            onTap: () => _openTrendChart(
                              context,
                              title: 'Performa Tenaga Kerja',
                              trendKey: 'score',
                              data: data,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insights,
                                size: 14,
                                color: AppColors.primary.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ketuk untuk melihat tren',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tombol Akordeon & Tombol Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showMore = !_showMore),
                        child: Row(
                          children: [
                            Text(
                              _showMore ? 'Lebih sedikit' : 'Lebih lengkap',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showMore
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),

                      _buildFilterButton(context, loadedState),
                    ],
                  ),
                ],
              ),
            ),

            // ─── RINCIAN ITEM SAAT DI-EXPAND (rgba(0,0,0,0.45)) ───
            if (_showMore)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Baris 1: Pencapaian Inspeksi & COC
                    Row(
                      children: [
                        if (penilaian.contains('PENCAPAIAN'))
                          Expanded(
                            child: _buildPerformItem(
                              context: context,
                              title: 'Pencapaian Inspeksi',
                              target: data.targetPencapainInspeksi,
                              realisasi: data.kepatuhan.toInt(),
                              progress: data.pointKepatuhan,
                              trendKey: 'kepatuhan',
                              data: data,
                            ),
                          ),
                        if (penilaian.contains('PENCAPAIAN') && penilaian.contains('COC'))
                          const SizedBox(width: 12),
                        if (penilaian.contains('COC'))
                          Expanded(
                            child: _buildPerformItem(
                              context: context,
                              title: 'COC',
                              target: data.targetCOC,
                              realisasi: data.coc.toInt(),
                              progress: data.pointCOC,
                              trendKey: 'coc',
                              data: data,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Baris 2: Kehadiran & Durasi Inspeksi
                    Row(
                      children: [
                        if (penilaian.contains('ABSENSI'))
                          Expanded(
                            child: _buildPerformItem(
                              context: context,
                              title: 'Kehadiran',
                              target: data.targetAbsensi,
                              realisasi: data.absensi.toInt(),
                              progress: data.pointAbsensi,
                              trendKey: 'absensi',
                              data: data,
                            ),
                          ),
                        if (penilaian.contains('ABSENSI') && penilaian.contains('DURASI'))
                          const SizedBox(width: 12),
                        if (penilaian.contains('DURASI'))
                          Expanded(
                            child: _buildPerformItem(
                              context: context,
                              title: 'Durasi Inspeksi',
                              target: data.ketentuan,
                              realisasi: data.durasi.toInt(),
                              progress: data.pointDurasi,
                              trendKey: 'durasi',
                              data: data,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
