import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'WO_ASSIGNED':
        return Icons.assignment_outlined;
      case 'WO_ACCEPTED':
        return Icons.check_circle_outline;
      case 'WO_REJECTED':
      case 'INSPEKSI_REJECTED':
        return Icons.cancel_outlined;
      case 'INSPEKSI_APPROVED':
        return Icons.thumb_up_alt_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'WO_ASSIGNED':
        return const Color(0xFF2563EB);
      case 'WO_ACCEPTED':
        return const Color(0xFF16A34A);
      case 'WO_REJECTED':
      case 'INSPEKSI_REJECTED':
        return const Color(0xFFDC2626);
      case 'INSPEKSI_APPROVED':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF4B5563);
    }
  }

  Color _getIconBg(String type) {
    switch (type) {
      case 'WO_ASSIGNED':
        return const Color(0xFFEFF6FF);
      case 'WO_ACCEPTED':
        return const Color(0xFFF0FDF4);
      case 'WO_REJECTED':
      case 'INSPEKSI_REJECTED':
        return const Color(0xFFFEF2F2);
      case 'INSPEKSI_APPROVED':
        return const Color(0xFFF0FDFA);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationCubit>()..fetchNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifikasi'),
          centerTitle: true,
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
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final cubit = context.read<NotificationCubit>();
                final bool? filter =
                    state is NotificationLoaded ? state.currentFilter : null;

                return Column(
                  children: [
                    // Header Card & Action
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
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
                          Text(
                            filter == false
                                ? 'Belum Dibaca'
                                : 'Semua Notifikasi',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => cubit.markAllAsRead(),
                            child: const Text(
                              'Tandai semua dibaca',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter Tabs: Semua vs Belum Dibaca
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  cubit.fetchNotifications(isRead: null),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: filter == null
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Semua',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: filter == null
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  cubit.fetchNotifications(isRead: false),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: filter == false
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Belum Dibaca',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: filter == false
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // List Notifikasi
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state is NotificationLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is NotificationError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(state.message),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        cubit.fetchNotifications(isRead: filter),
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (state is NotificationLoaded) {
                            if (state.items.isEmpty) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications_off_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Tidak ada notifikasi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () =>
                                  cubit.fetchNotifications(isRead: filter),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  24,
                                ),
                                itemCount: state.items.length +
                                    (state.isLoadingMore ? 1 : 0),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  if (index == state.items.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final item = state.items[index];
                                  final formattedDate = DateFormat(
                                    'd MMM yyyy, HH:mm',
                                    'id_ID',
                                  ).format(item.createdAt);

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: item.isRead
                                            ? Colors.grey.shade200
                                            : AppColors.primary
                                                .withAlpha(80),
                                        width: item.isRead ? 1 : 1.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: _getIconBg(item.type),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getIcon(item.type),
                                            color: _getIconColor(item.type),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: item.isRead
                                                            ? FontWeight.w600
                                                            : FontWeight.bold,
                                                        color: const Color(
                                                          0xFF1E293B,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (!item.isRead)
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      margin:
                                                          const EdgeInsets.only(
                                                        left: 6,
                                                      ),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.message,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                  height: 1.35,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
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
}
