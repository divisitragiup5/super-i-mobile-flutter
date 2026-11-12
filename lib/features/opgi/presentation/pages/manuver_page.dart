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
import '../widgets/manuver_item_card.dart';

class ManuverPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const ManuverPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<ManuverPage> createState() => _ManuverPageState();
}

class _ManuverPageState extends State<ManuverPage> {
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiManuverCubit>().loadManuverList(
          widget.garduIndukId,
          widget.garduIndukNama,
          forceRefresh: forceRefresh,
        );
  }

  void _navigateToInput() async {
    final result = await context.push(
      AppRoutes.inputManuver,
      extra: {
        'garduIndukId': widget.garduIndukId,
        'garduIndukNama': widget.garduIndukNama,
      },
    );
    if (result == true) {
      _fetch();
    } else {
      // Re-fetch to update draft indicator if draft was saved/modified
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kegiatan Manuver 20kV'),
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
            final List<ManuverItemModel> items = state is OpgiManuverLoaded
                ? state.items
                : (state is OpgiManuverSuccess && state.items != null)
                    ? state.items!
                    : (state is OpgiManuverError && state.items != null)
                        ? state.items!
                        : cubit.cachedItems;

            final List<Map<String, dynamic>> drafts = state is OpgiManuverLoaded
                ? state.drafts
                : (state is OpgiManuverSuccess && state.drafts != null)
                    ? state.drafts!
                    : (state is OpgiManuverError && state.drafts != null)
                        ? state.drafts!
                        : cubit.cachedDrafts;

            final hasDraft = drafts.isNotEmpty;
            final isLoading = state is OpgiManuverLoading && items.isEmpty;

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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            AppButton(
                              text: 'Tambah Kegiatan Manuver',
                              variant: ButtonVariant.outlined,
                              height: 42,
                              onPressed: _navigateToInput,
                            ),
                            if (hasDraft)
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
                      child: LoadingIndicator(text: 'Memuat data manuver...'),
                    )
                  else if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: EmptyStateWidget(
                        title: 'Belum Ada Kegiatan Manuver',
                        description: 'Tekan tombol di atas untuk menambah kegiatan manuver baru.',
                      ),
                    )
                  else ...[
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ManuverItemCard(
                          item: item,
                          isAdminSuper: isAdminSuper,
                          isDeleting: _deletingId == item.id,
                          onView: () async {
                            await context.push(
                              AppRoutes.dataManuver,
                              extra: {
                                'manuverId': item.id,
                                'penyulangId': item.penyulang.id,
                                'nama': item.penyulang.nama,
                                'tipeManuver': item.tipeManuver,
                                'garduInduk': {
                                  'id': widget.garduIndukId,
                                  'nama': widget.garduIndukNama,
                                },
                                'isClose': item.isClose.toString(),
                              },
                            );
                            _fetch();
                          },
                          onDelete: () async {
                            setState(() => _deletingId = item.id);
                            await context.read<OpgiManuverCubit>().deleteManuver(
                                  item.id,
                                  widget.garduIndukId,
                                  widget.garduIndukNama,
                                );
                            if (mounted) {
                              setState(() => _deletingId = null);
                            }
                          },
                        ),
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
