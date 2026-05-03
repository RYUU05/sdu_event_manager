import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/club_application.dart';
import '../../domain/repositories/application_repository.dart';
import '../bloc/admin_application_bloc.dart';

/// Панель модератора (super_admin). Открывается из SettingsPage.
@RoutePage()
class AdminApplicationsPage extends StatelessWidget {
  const AdminApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<ApplicationRepository>();

    return BlocProvider(
      create: (_) => AdminApplicationBloc(repo),
      child: BlocListener<AdminApplicationBloc, AdminApplicationState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Панель модератора'),
            centerTitle: true,
          ),
          body: StreamBuilder<List<ClubApplication>>(
            stream: repo.watchPendingApplications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }

              final applications = snapshot.data ?? [];

              if (applications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Нет заявок на рассмотрении',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  return _ApplicationCard(application: applications[i]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Карточка заявки ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final ClubApplication application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminApplicationBloc>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с категорией
            Row(
              children: [
                Expanded(
                  child: Text(
                    application.clubName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _CategoryChip(label: application.category),
              ],
            ),
            const SizedBox(height: 6),

            // Кто подал
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  application.userName,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Описание
            Text(
              application.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Кнопки действий
            BlocBuilder<AdminApplicationBloc, AdminApplicationState>(
              builder: (context, state) {
                final loading = state is AdminLoading;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: loading
                            ? null
                            : () => _confirmReject(context, bloc),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          'Отклонить',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: loading
                            ? null
                            : () => _confirmApprove(context, bloc),
                        icon: const Icon(Icons.check),
                        label: const Text('Одобрить'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
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

  // Диалог подтверждения одобрения
  void _confirmApprove(BuildContext context, AdminApplicationBloc bloc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Одобрить заявку?'),
        content: Text(
          'Клуб "${application.clubName}" будет создан, '
          'а ${application.userName} получит роль club_admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(ApproveApplicationEvent(application));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Одобрить'),
          ),
        ],
      ),
    );
  }

  // Диалог отклонения с необязательной причиной
  void _confirmReject(BuildContext context, AdminApplicationBloc bloc) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Отклонить заявку?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Можете указать причину отказа (необязательно):'),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Причина...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(RejectApplicationEvent(
                application.id,
                note: noteCtrl.text.trim(),
              ));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );
  }
}

// ─── Chip категории ───────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
