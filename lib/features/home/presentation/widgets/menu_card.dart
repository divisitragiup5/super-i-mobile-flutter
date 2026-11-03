import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/menu_item_model.dart';

import 'package:go_router/go_router.dart';


class MenuCard extends StatelessWidget {
  final MenuItemModel item;

  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (item.params != null && item.params!.isNotEmpty) {
            context.push(
              item.route,
              extra: item.params,
            );
          } else {
            context.push(item.route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
