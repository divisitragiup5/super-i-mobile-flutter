import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_sutm_map_card.dart';
import '../cubit/wo_inspeksi_cubit.dart';

class RuteInspeksiPage extends StatefulWidget {
  const RuteInspeksiPage({super.key});

  @override
  State<RuteInspeksiPage> createState() => _RuteInspeksiPageState();
}

class _RuteInspeksiPageState extends State<RuteInspeksiPage> {
  late DateTime _today;
  late String _selectedDateString;
  late List<DateTime> _calendarDates;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDateString = DateFormat('yyyy-MM-dd').format(_today);
    _calendarDates = List.generate(31, (index) => _today.add(Duration(days: index)));
    context.read<WoInspeksiCubit>().fetchToday(_selectedDateString);
  }

  void _onDateSelected(DateTime date) {
    final str = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      _selectedDateString = str;
    });
    context.read<WoInspeksiCubit>().fetchToday(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Inspeksi'),
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
                    final isToday = dateStr == DateFormat('yyyy-MM-dd').format(_today);

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
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('MMM', 'id_ID').format(date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white70 : Colors.grey,
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
                                color: isSelected ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Map and Workorder List
              Expanded(
                child: BlocBuilder<WoInspeksiCubit, WoInspeksiState>(
                  builder: (context, state) {
                    if (state is WoInspeksiLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = state is WoInspeksiLoaded
                        ? state.todayWorkOrders
                        : [];

                    final sutmItems = items
                        .expand((wo) => wo.items)
                        .where((i) => i.latitude != null && i.longitude != null)
                        .map((i) => SutmMapItem(
                              idAsset: i.idAsset,
                              name: i.nama,
                              latitude: i.latitude,
                              longitude: i.longitude,
                              color: AppColors.primary,
                              rawData: i,
                            ))
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (sutmItems.isNotEmpty) ...[
                          GoogleSutmMapCard(
                            items: sutmItems,
                            height: 220,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daftar Rute Inspeksi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
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
                                'Tidak ada jadwal rute inspeksi di tanggal ini',
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
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Jumlah SUTM: ${item.totalSutm} Item'),
                                    Text('Status: ${item.status}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {
                                  context.push(
                                    AppRoutes.detailWorkorderToday,
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
