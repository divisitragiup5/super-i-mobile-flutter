import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/role_constants.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/input_container.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/opgi_manuver_model.dart';
import '../cubit/opgi_manuver_cubit.dart';
import '../widgets/manuver_progress_item_card.dart';

class DataManuverPage extends StatefulWidget {
  final int manuverId;
  final int penyulangId;
  final String penyulangNama;
  final String tipeManuver;
  final int garduIndukId;
  final String garduIndukNama;
  final bool isClose;

  const DataManuverPage({
    super.key,
    required this.manuverId,
    required this.penyulangId,
    required this.penyulangNama,
    required this.tipeManuver,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.isClose = false,
  });

  @override
  State<DataManuverPage> createState() => _DataManuverPageState();
}

class _DataManuverPageState extends State<DataManuverPage> {
  int? _deletingProgressId;
  late bool _isClosedCurrent;

  String get _draftKey =>
      '${widget.garduIndukNama}-${widget.penyulangNama}-${widget.tipeManuver}';

  @override
  void initState() {
    super.initState();
    _isClosedCurrent = widget.isClose;
    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiManuverCubit>().loadManuverProgress(
          widget.manuverId,
          _draftKey,
          forceRefresh: forceRefresh,
        );
  }

  void _navigateToInputProgress() async {
    final result = await context.push(
      AppRoutes.inputManuverProgress,
      extra: {
        'garduInduk': widget.garduIndukNama,
        'garduIndukId': widget.garduIndukId,
        'manuverId': widget.manuverId,
        'nama': widget.penyulangNama,
        'tipeManuver': widget.tipeManuver,
        'penyulangId': widget.penyulangId,
      },
    );
    if (result == 'CLOSE') {
      // Pop back to manuver list as manuver is now finished
      if (mounted) context.pop();
    } else {
      _fetch();
    }
  }

  void _navigateToUpdateProgress(dynamic item, bool isLast) async {
    final res = await context.push(
      AppRoutes.updateManuverProgress,
      extra: {
        'garduInduk': widget.garduIndukNama,
        'garduIndukId': widget.garduIndukId,
        'manuverId': widget.manuverId,
        'nama': widget.penyulangNama,
        'tipeManuver': widget.tipeManuver,
        'penyulangId': widget.penyulangId,
        'data': item.toJson(),
        'isLastProgress': isLast.toString(),
      },
    );
    if (res == 'CLOSE') {
      if (mounted) context.pop();
    } else {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kegiatan Manuver'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _fetch(forceRefresh: true),
          ),
        ],
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiManuverCubit, OpgiManuverState>(
          listener: (context, state) {
            if (state is OpgiManuverSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (state is OpgiManuverError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            final authState = context.watch<AuthBloc>().state;
            final isAdminSuper = authState is AuthAuthenticated &&
                authState.user.roles.contains(AppRoles.adminSuper);

            final cubit = context.read<OpgiManuverCubit>();
            final List<ManuverProgressModel> items = state is OpgiManuverProgressLoaded
                ? state.items
                : (state is OpgiManuverSuccess && state.progressItems != null)
                    ? state.progressItems!
                    : (state is OpgiManuverError && state.progressItems != null)
                        ? state.progressItems!
                        : cubit.cachedProgressItems;

            final List<Map<String, dynamic>> drafts = state is OpgiManuverProgressLoaded
                ? state.drafts
                : (state is OpgiManuverSuccess && state.drafts != null)
                    ? state.drafts!
                    : (state is OpgiManuverError && state.drafts != null)
                        ? state.drafts!
                        : cubit.cachedProgressDrafts;

            final hasDraft = drafts.isNotEmpty;
            final isLoading = state is OpgiManuverLoading && items.isEmpty;

            // Check if any progress item is CLOSE
            final isAnyClose = _isClosedCurrent || items.any((p) => p.isClose);
            final lastProgressId = items.isNotEmpty ? items.last.id : null;

            return RefreshIndicator(
              onRefresh: () async => _fetch(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Container Header
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputWithLabel(
                          label: 'Gardu Induk',
                          child: Text(
                            widget.garduIndukNama,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ),
                        InputWithLabel(
                          label: 'Penyulang',
                          child: Text(
                            widget.penyulangNama,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ),
                        InputWithLabel(
                          label: 'Tipe Manuver',
                          child: Text(
                            widget.tipeManuver,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            AppButton(
                              text: 'Tambah Progress',
                              variant: ButtonVariant.outlined,
                              height: 42,
                              onPressed: (isAdminSuper || !isAnyClose) ? _navigateToInputProgress : null,
                            ),
                            if (hasDraft && (isAdminSuper || !isAnyClose))
                              const Positioned(
                                right: 12,
                                child: Icon(
                                  Icons.drafts,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: LoadingIndicator(text: 'Memuat riwayat progress...'),
                    )
                  else if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: EmptyStateWidget(
                        title: 'Belum Ada Progress',
                        description: 'Tekan tombol di atas untuk menambah progress manuver.',
                      ),
                    )
                  else ...[
                    ...items.map((item) {
                      final isLast = item.id == lastProgressId;
                      return ManuverProgressItemCard(
                        item: item,
                        isAdminSuper: isAdminSuper,
                        isManuverClose: widget.isClose,
                        isDeleting: _deletingProgressId == item.id,
                        onUpdate: () => _navigateToUpdateProgress(item, isLast),
                        onDelete: () async {
                          setState(() => _deletingProgressId = item.id);
                          await context.read<OpgiManuverCubit>().deleteManuverProgress(
                                item.id,
                                widget.manuverId,
                                _draftKey,
                              );
                          if (mounted) {
                            setState(() => _deletingProgressId = null);
                          }
                        },
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
