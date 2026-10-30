import 'package:flutter/material.dart';

import '../../../../core/constants/role_constants.dart';
import '../../../../core/router/route_constants.dart';

class MenuItemModel {
  final String label;
  final IconData icon;
  final String route;
  final Map<String, dynamic>? params;
  final List<String> allowedRoles;

  const MenuItemModel({
    required this.label,
    required this.icon,
    required this.route,
    this.params,
    required this.allowedRoles,
  });

  /// Daftar lengkap seluruh 31 menu operasional sistem Super-I / GAMA
  static const List<MenuItemModel> allMenus = [
    // ─────────────────────────────────────────────────────────────
    // 1. MODUL LINE WALKER (Transmisi SUTT / SUTET)
    // ─────────────────────────────────────────────────────────────
    MenuItemModel(
      label: 'Waterpass',
      icon: Icons.square_foot,
      route: '/waterpass',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
      ],
    ),
    MenuItemModel(
      label: 'Pembumian',
      icon: Icons.electrical_services,
      route: '/pembumian',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
      ],
    ),
    MenuItemModel(
      label: 'Pembumian',
      icon: Icons.electrical_services,
      route: '/summary-pembumian',
      allowedRoles: [AppRoles.koordinatorNewSrintami],
    ),
    MenuItemModel(
      label: 'PPL',
      icon: Icons.engineering,
      route: '/ppl',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
      ],
    ),
    MenuItemModel(
      label: 'Kegiatan Sosial',
      icon: Icons.groups,
      route: '/kegiatan-sosial',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
      ],
    ),
    MenuItemModel(
      label: 'PPL',
      icon: Icons.engineering,
      route: '/summary-ppl',
      allowedRoles: [AppRoles.koordinatorNewSrintami],
    ),
    MenuItemModel(
      label: 'Riwayat Pembumian',
      icon: Icons.description_outlined,
      route: '/riwayat-pembumian',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
        AppRoles.koordinatorNewSrintami,
        AppRoles.teamLeaderGi,
        AppRoles.viewerPlnUit,
        AppRoles.viewerPlnUpt,
        AppRoles.viewerPlnUltg,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat PPL',
      icon: Icons.assignment_outlined,
      route: '/riwayat-ppl',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
        AppRoles.koordinatorNewSrintami,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat PPL',
      icon: Icons.assignment_outlined,
      route: '/summary-riwayat-ppl',
      allowedRoles: [
        AppRoles.teamLeaderGi,
        AppRoles.viewerPlnUit,
        AppRoles.viewerPlnUpt,
        AppRoles.viewerPlnUltg,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat Kegiatan Sosial',
      icon: Icons.history,
      route: '/riwayat-kegiatan-sosial',
      allowedRoles: [
        AppRoles.koordinatorLineWalker,
        AppRoles.petugasLineWalker,
        AppRoles.teamLeaderGi,
        AppRoles.viewerPlnUit,
        AppRoles.viewerPlnUpt,
        AppRoles.viewerPlnUltg,
      ],
    ),
    MenuItemModel(
      label: 'Ketenagakerjaan',
      icon: Icons.badge_outlined,
      route: '/ketenagakerjaan',
      allowedRoles: [AppRoles.petugasLineWalker],
    ),
    MenuItemModel(
      label: 'Ketenagakerjaan',
      icon: Icons.badge_outlined,
      route: '/summary-ketenagakerjaan',
      allowedRoles: [
        AppRoles.koordinatorNewSrintami,
        AppRoles.teamLeaderGi,
        AppRoles.koordinatorLineWalker,
        AppRoles.viewerPlnUit,
        AppRoles.viewerPlnUpt,
        AppRoles.viewerPlnUltg,
      ],
    ),

    // ─────────────────────────────────────────────────────────────
    // 2. MODUL PRESENSI (ABSENSI LAPANGAN)
    // ─────────────────────────────────────────────────────────────
    MenuItemModel(
      label: 'Absen',
      icon: Icons.how_to_reg_outlined,
      route: AppRoutes.absen,
      allowedRoles: [
        AppRoles.operatorGi20kv,
        AppRoles.operatorGi150kv,
        AppRoles.timHar20kv,
        AppRoles.timHarPromet20kv,
        AppRoles.k3Har20kv,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat Absen',
      icon: Icons.fact_check_outlined,
      route: '/riwayat-absen',
      allowedRoles: [
        AppRoles.operatorGi20kv,
        AppRoles.timHar20kv,
        AppRoles.timHarPromet20kv,
        AppRoles.k3Har20kv,
      ],
    ),
    MenuItemModel(
      label: 'Jadwal',
      icon: Icons.calendar_month_outlined,
      route: '/data-shift',
      allowedRoles: [
        AppRoles.operatorGi20kv,
        AppRoles.timHar20kv,
        AppRoles.timHarPromet20kv,
        AppRoles.k3Har20kv,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat Penilaian',
      icon: Icons.archive_outlined,
      route: '/history-penilaian',
      allowedRoles: [
        AppRoles.operatorGi20kv,
        AppRoles.timHar20kv,
        AppRoles.timHarPromet20kv,
        AppRoles.k3Har20kv,
      ],
    ),

    // ─────────────────────────────────────────────────────────────
    // 3. MODUL OPGI 20KV (OPERASI GARDU INDUK)
    // ─────────────────────────────────────────────────────────────
    MenuItemModel(
      label: 'Input Realisasi',
      icon: Icons.note_alt_outlined,
      route: '/gardu-induk-20kv',
      params: {'redirectPath': '/input-realisasi'},
      allowedRoles: [AppRoles.operatorGi20kv],
    ),
    MenuItemModel(
      label: 'IL 1',
      icon: Icons.checklist_rtl_outlined,
      route: '/gardu-induk-20kv',
      params: {'redirectPath': '/il-1'},
      allowedRoles: [AppRoles.operatorGi20kv],
    ),
    MenuItemModel(
      label: 'Manuver',
      icon: Icons.alt_route_outlined,
      route: '/gardu-induk-20kv',
      params: {'redirectPath': '/manuver'},
      allowedRoles: [AppRoles.operatorGi20kv],
    ),
    MenuItemModel(
      label: 'Anomali',
      icon: Icons.warning_amber_rounded,
      route: '/gardu-induk-20kv',
      params: {'redirectPath': '/anomali-gi'},
      allowedRoles: [AppRoles.operatorGi20kv],
    ),

    // ─────────────────────────────────────────────────────────────
    // 4. MODUL DISTRIBUSI (SUTM - Saluran Udara Tegangan Menengah)
    // ─────────────────────────────────────────────────────────────
    MenuItemModel(
      label: 'Workorder Inspeksi',
      icon: Icons.assignment_outlined,
      route: '/workorder-inspeksi',
      allowedRoles: [AppRoles.petugasInspeksiSutm],
    ),
    MenuItemModel(
      label: 'Inspeksi YANTEK',
      icon: Icons.handyman_outlined,
      route: '/inspeksi-yantek',
      allowedRoles: [AppRoles.petugasYantek],
    ),
    MenuItemModel(
      label: 'Rute Inspeksi',
      icon: Icons.map_outlined,
      route: '/rute-inspeksi',
      allowedRoles: [AppRoles.petugasInspeksiSutm],
    ),
    MenuItemModel(
      label: 'Inspeksi Pemeliharaan',
      icon: Icons.build_circle_outlined,
      route: '/workorder-pemeliharaan',
      allowedRoles: [AppRoles.petugasPemeliharaanSutm],
    ),
    MenuItemModel(
      label: 'Rute Pemeliharaan',
      icon: Icons.timeline_outlined,
      route: '/rute-pemeliharaan',
      allowedRoles: [AppRoles.petugasPemeliharaanSutm],
    ),
    MenuItemModel(
      label: 'Riwayat Inspeksi',
      icon: Icons.manage_history,
      route: '/riwayat-inspeksi',
      allowedRoles: [
        AppRoles.petugasInspeksiSutm,
        AppRoles.koordinatorInspeksiSutm,
        AppRoles.plnUlp,
        AppRoles.plnUp3,
        AppRoles.petugasYantek,
      ],
    ),
    MenuItemModel(
      label: 'Validasi Inspeksi',
      icon: Icons.dashboard_customize_outlined,
      route: '/validasi-inspeksi',
      allowedRoles: [
        AppRoles.koordinatorInspeksiSutm,
        AppRoles.plnUlp,
        AppRoles.plnUp3,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat Pemeliharaan',
      icon: Icons.manage_history,
      route: '/riwayat-pemeliharaan',
      allowedRoles: [
        AppRoles.petugasPemeliharaanSutm,
        AppRoles.koordinatorPemeliharaanSutm,
        AppRoles.plnUlp,
        AppRoles.plnUp3,
      ],
    ),
    MenuItemModel(
      label: 'Validasi Pemeliharaan',
      icon: Icons.dashboard_customize_outlined,
      route: '/validasi-pemeliharaan',
      allowedRoles: [
        AppRoles.koordinatorPemeliharaanSutm,
        AppRoles.plnUlp,
        AppRoles.plnUp3,
      ],
    ),
    MenuItemModel(
      label: 'Riwayat Penilaian',
      icon: Icons.scoreboard_outlined,
      route: '/riwayat-penilaian-inspeksi',
      allowedRoles: [AppRoles.petugasInspeksiSutm],
    ),
    MenuItemModel(
      label: 'Riwayat Penilaian',
      icon: Icons.scoreboard_outlined,
      route: '/riwayat-penilaian-har',
      allowedRoles: [AppRoles.petugasPemeliharaanSutm],
    ),
  ];
}
