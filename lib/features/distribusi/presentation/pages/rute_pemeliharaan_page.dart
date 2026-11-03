import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_map_viewer.dart';
import '../cubit/wo_pemeliharaan_cubit.dart';

class RutePemeliharaanPage extends StatefulWidget {
  const RutePemeliharaanPage({super.key});

  @override
  State<RutePemeliharaanPage> createState() => _RutePemeliharaanPageState();
}

class _RutePemeliharaanPageState extends State<RutePemeliharaanPage> {
  late DateTime _today;
  late String _selectedDateString;
  late List<DateTime> _calendarDates;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDateString = DateFormat('yyyy-MM-dd').format(_today);
    _calendarDates =
        List.generate(31, (index) => _today.add(Duration(days: index)));
    context.read<WoPemeliharaanCubit>().fetchToday(_selectedDateString);
  }

  void _onDateSelected(DateTime date) {
    final str = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      _selectedDateString = str;
    });
    context.read<WoPemeliharaanCubit>().fetchToday(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Pemeliharaan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.backgroundLight),
            ),
          ),
          Column(
            children: [
              // 1. Horizontal Date Picker
              Container(
                height: 85,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _calendarDates.length,
                  itemBuilder: (context, index) {
                    final date = _calendarDates[index];
                    final dateStr = DateFormat('yyyy-MM-dd').format(date);
                    final isSelected = dateStr == _selectedDateString;
                    final isToday =
                        dateStr == DateFormat('yyyy-MM-dd').format(_today);

                    return GestureDetector(
                      onTap: () => _onDateSelected(date),
                      child: Container(
                        width: 58,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : isToday
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('MMM', 'id_ID')
                                  .format(date)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white70 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? AppColors.primary
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('E', 'id_ID').format(date),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Map & List
              Expanded(
                child: BlocBuilder<WoPemeliharaanCubit, WoPemeliharaanState>(
                  builder: (context, state) {
                    if (state is WoPemeliharaanLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = state is WoPemeliharaanLoaded
                        ? state.todayWorkOrders
                        : [];

                    final allPins = items
                        .expand((wo) => wo.items)
                        .where((i) => i.latitude != null && i.longitude != null)
                        .map((i) => MapPinItem(
                              id: i.id.toString(),
                              title: i.nama,
                              subtitle: i.idAsset,
                              latitude: i.latitude!,
                              longitude: i.longitude!,
                              color: Colors.amber.shade700,
                            ))
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (allPins.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: FieldMapViewer(
                              pins: allPins,
                              height: 220,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daftar Rute Pemeliharaan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${items.length} Item',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak ada jadwal rute pemeliharaan di tanggal ini',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...items.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  'WO #${item.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                    'Jumlah SUTM: ${item.totalSutm} Item • Status: ${item.status}'),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {
                                  context.push(
                                    AppRoutes.detailWorkorderPemeliharaanToday,
                                    extra: item,
                                  );
                                },
                              ),
                            );
                          }),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
