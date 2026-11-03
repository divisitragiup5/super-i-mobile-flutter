import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/month_year_picker_dialog.dart';
import '../../data/models/data_shift_model.dart';
import '../cubit/data_shift_cubit.dart';
import '../cubit/data_shift_state.dart';

class DataShiftPage extends StatefulWidget {
  const DataShiftPage({super.key});

  @override
  State<DataShiftPage> createState() => _DataShiftPageState();
}

class _DataShiftPageState extends State<DataShiftPage> {
  late int _selectedMonth; // 0-11
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month - 1;
    _selectedYear = now.year;
  }

  void _showMonthPicker(BuildContext context, DataShiftCubit cubit) async {
    final result = await MonthYearPickerDialog.show(
      context,
      initialMonth: _selectedMonth + 1,
      initialYear: _selectedYear,
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result.month - 1;
        _selectedYear = result.year;
      });
      cubit.fetchShifts(bulan: _selectedMonth, tahun: _selectedYear);
    }
  }

  void _showGantiJadwalSheet(
    BuildContext context,
    ShiftItemModel shift,
    List<ShiftItemModel> allShifts,
    DataShiftCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return _GantiJadwalBottomSheet(
          shift: shift,
          allShifts: allShifts,
          onConfirm: (tanggalBaru) async {
            final success = await cubit.gantiJadwal(
              shiftId: shift.id,
              tanggalBaru: tanggalBaru,
            );
            if (bottomSheetCtx.mounted) {
              Navigator.pop(bottomSheetCtx);
            }
            if (success && context.mounted) {
              AppSnackbar.showSuccess(
                context,
                'Jadwal shift berhasil dipindahkan',
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DataShiftCubit>()
        ..fetchShifts(bulan: _selectedMonth, tahun: _selectedYear),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal Shift'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
            BlocConsumer<DataShiftCubit, DataShiftState>(
              listener: (context, state) {
                if (state is DataShiftLoaded) {
                  if (state.errorMessage != null) {
                    AppSnackbar.showError(context, state.errorMessage!);
                  }
                }
              },
              builder: (context, state) {
                final cubit = context.read<DataShiftCubit>();

                return Column(
                  children: [
                    // Month Picker Header
                    _buildMonthFilterHeader(context, cubit),

                    // Content
                    Expanded(
                      child: _buildContent(context, state, cubit),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthFilterHeader(BuildContext context, DataShiftCubit cubit) {
    final date = DateTime(_selectedYear, _selectedMonth + 1, 1);
    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(date);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Periode Shift',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    monthStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => _showMonthPicker(context, cubit),
            icon: const Icon(Icons.filter_list, size: 16),
            label: const Text('Ganti Bulan'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DataShiftState state,
    DataShiftCubit cubit,
  ) {
    if (state is DataShiftLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DataShiftError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => cubit.fetchShifts(
                  bulan: _selectedMonth,
                  tahun: _selectedYear,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is DataShiftLoaded) {
      if (state.shifts.isEmpty) {
        return Center(
          child: RefreshIndicator(
            onRefresh: () => cubit.fetchShifts(
              bulan: _selectedMonth,
              tahun: _selectedYear,
            ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'Tidak ada jadwal shift untuk bulan ini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => cubit.fetchShifts(
          bulan: _selectedMonth,
          tahun: _selectedYear,
        ),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.shifts.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildSummaryCard(state.shifts.length);
            }

            final shift = state.shifts[index - 1];
            return _buildShiftCard(context, shift, state.shifts, cubit);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSummaryCard(int totalShifts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jadwal Bulan Ini',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$totalShifts Hari Shift Terjadwal',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.swap_horiz, size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Bisa Ditukar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(
    BuildContext context,
    ShiftItemModel shift,
    List<ShiftItemModel> allShifts,
    DataShiftCubit cubit,
  ) {
    final shiftDate = DateTime(shift.tahun, shift.bulan + 1, shift.tanggal);
    final dayShort = DateFormat('EEE', 'id_ID').format(shiftDate).toUpperCase();
    final dayFull = DateFormat('EEEE', 'id_ID').format(shiftDate);
    final dateNum = shift.tanggal.toString().padLeft(2, '0');

    final identifier = shift.ketentuan?.identifier?.toUpperCase() ?? '-';
    final shiftConfig = _getShiftConfig(identifier);

    final isDiganti = shift.statusJadwal == 'DIGANTI';
    final isHasilGanti = shift.statusJadwal == 'HASIL_GANTI';
    final isOngoing = shift.isOngoing;

    String startHour = shift.ketentuan?.startHour?.toString().padLeft(2, '0') ?? '00';
    String startMinute = shift.ketentuan?.startMinute?.toString().padLeft(2, '0') ?? '00';
    String endHour = shift.ketentuan?.endHour?.toString().padLeft(2, '0') ?? '00';
    String endMinute = shift.ketentuan?.endMinute?.toString().padLeft(2, '0') ?? '00';

    return Container(
      decoration: BoxDecoration(
        color: isDiganti
            ? Colors.white.withValues(alpha: 0.7)
            : isOngoing
                ? Colors.white
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOngoing
              ? AppColors.primary
              : isDiganti
                  ? Colors.grey.shade300
                  : const Color(0xFFF1F5F9),
          width: isOngoing ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Date Box Badge
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isOngoing
                  ? AppColors.primary
                  : isDiganti
                      ? Colors.grey.shade100
                      : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOngoing
                    ? AppColors.primary
                    : isDiganti
                        ? Colors.grey.shade300
                        : Colors.teal.shade100,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayShort,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isOngoing
                        ? Colors.teal.shade100
                        : isDiganti
                            ? Colors.grey
                            : AppColors.primary,
                  ),
                ),
                Text(
                  dateNum,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isOngoing
                        ? Colors.white
                        : isDiganti
                            ? Colors.grey.shade600
                            : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dayFull,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDiganti ? Colors.grey : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: shiftConfig.bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: shiftConfig.borderColor),
                      ),
                      child: Text(
                        'Shift $identifier (${shiftConfig.name})',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: shiftConfig.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Status badges
                if (isDiganti)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      'Dipindah',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  )
                else if (isHasilGanti)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: const Text(
                      'Pengganti',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (isOngoing)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Text(
                      'Sedang Berjalan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),

                // Shift Hours
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: isDiganti ? Colors.grey : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$startHour:$startMinute - $endHour:$endMinute WIB',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: isDiganti ? TextDecoration.lineThrough : null,
                        color: isDiganti ? Colors.grey : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Swap Button
          if (shift.canBeSwapped)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.primary),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onPressed: () => _showGantiJadwalSheet(
                context,
                shift,
                allShifts,
                cubit,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz, size: 14),
                  SizedBox(width: 4),
                  Text('Ganti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  _ShiftConfig _getShiftConfig(String id) {
    switch (id) {
      case 'P':
        return _ShiftConfig(
          name: 'Pagi',
          bgColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade200,
          textColor: Colors.amber.shade800,
        );
      case 'S':
        return _ShiftConfig(
          name: 'Siang',
          bgColor: Colors.lightBlue.shade50,
          borderColor: Colors.lightBlue.shade200,
          textColor: Colors.lightBlue.shade800,
        );
      case 'M':
        return _ShiftConfig(
          name: 'Malam',
          bgColor: Colors.indigo.shade50,
          borderColor: Colors.indigo.shade200,
          textColor: Colors.indigo.shade800,
        );
      case 'L':
      case 'OFF':
        return _ShiftConfig(
          name: 'Libur',
          bgColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          textColor: Colors.grey.shade700,
        );
      default:
        return _ShiftConfig(
          name: id,
          bgColor: Colors.teal.shade50,
          borderColor: Colors.teal.shade200,
          textColor: AppColors.primary,
        );
    }
  }
}

class _ShiftConfig {
  final String name;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  _ShiftConfig({
    required this.name,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}

class _GantiJadwalBottomSheet extends StatefulWidget {
  final ShiftItemModel shift;
  final List<ShiftItemModel> allShifts;
  final Function(int tanggalBaru) onConfirm;

  const _GantiJadwalBottomSheet({
    required this.shift,
    required this.allShifts,
    required this.onConfirm,
  });

  @override
  State<_GantiJadwalBottomSheet> createState() => _GantiJadwalBottomSheetState();
}

class _GantiJadwalBottomSheetState extends State<_GantiJadwalBottomSheet> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final totalDaysInMonth = DateTime(
      widget.shift.tahun,
      widget.shift.bulan + 2,
      0,
    ).day;

    final occupiedDays = widget.allShifts
        .where((s) => s.id != widget.shift.id && s.statusJadwal != 'DIGANTI')
        .map((s) => s.tanggal)
        .toSet();

    final originDate = DateTime(
      widget.shift.tahun,
      widget.shift.bulan + 1,
      widget.shift.tanggal,
    );
    final originStr = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(originDate);

    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(originDate);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ganti Hari Shift',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Origin shift info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shift saat ini:',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Shift ${widget.shift.ketentuan?.identifier ?? '-'} · $originStr',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Pilih tanggal baru ($monthStr)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Grid of days
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(totalDaysInMonth, (index) {
              final d = index + 1;
              final thisDate = DateTime(widget.shift.tahun, widget.shift.bulan + 1, d);

              final isPast = thisDate.isBefore(startOfToday);
              final isOrigin = d == widget.shift.tanggal;
              final isOccupied = occupiedDays.contains(d);
              final isDisabled = isPast || isOrigin || isOccupied;

              final isSelected = _selectedDay == d;

              return InkWell(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          _selectedDay = d;
                        });
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isDisabled
                            ? Colors.grey.shade100
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isDisabled
                              ? Colors.grey.shade200
                              : AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$d',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isDisabled
                                ? Colors.grey.shade400
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _selectedDay == null
                ? null
                : () {
                    final targetDate = DateTime(
                      widget.shift.tahun,
                      widget.shift.bulan + 1,
                      _selectedDay!,
                    );
                    final targetStr = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(targetDate);

                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Konfirmasi Pindah Shift'),
                        content: Text(
                          'Shift ${widget.shift.ketentuan?.identifier ?? '-'} $originStr akan dipindah ke $targetStr.\n\nShift di tanggal asal tidak dapat digunakan untuk absen dan jadwal tidak dapat diganti lagi. Lanjutkan?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              widget.onConfirm(_selectedDay!);
                            },
                            child: const Text('Ya, Pindahkan'),
                          ),
                        ],
                      ),
                    );
                  },
            child: const Text(
              'Pindahkan Shift',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
