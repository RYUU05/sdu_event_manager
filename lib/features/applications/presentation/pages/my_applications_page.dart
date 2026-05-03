import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../../domain/entities/club_application.dart';
import '../bloc/club_application_bloc.dart';

/// Список заявок, поданных текущим студентом
@RoutePage()
class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<ClubApplicationBloc>();
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      bloc.add(LoadMyApplicationsEvent(authState.user.id));
    }

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои заявки'),
          centerTitle: true,
        ),
        body: BlocBuilder<ClubApplicationBloc, ClubApplicationState>(
          builder: (context, state) {
            if (state is ApplicationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ApplicationError) {
              return Center(child: Text(state.message));
            }
            if (state is MyApplicationsLoaded) {
              if (state.applications.isEmpty) {
                return const _EmptyState();
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _ApplicationStatusCard(app: state.applications[i]),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// ─── Карточка с статусом ─────────────────────────────────────────────────────

class _ApplicationStatusCard extends StatelessWidget {
  final ClubApplication app;
  const _ApplicationStatusCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _statusInfo(app.status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название + статус
            Row(
              children: [
                Expanded(
                  child: Text(
                    app.clubName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              app.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            // Причина отказа (если есть)
            if (app.status == ApplicationStatus.rejected &&
                app.reviewNote != null &&
                app.reviewNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Причина: ${app.reviewNote}',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _statusInfo(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return (Colors.orange, Icons.schedule_outlined, 'На рассмотрении');
      case ApplicationStatus.approved:
        return (Colors.green, Icons.check_circle_outline, 'Одобрено');
      case ApplicationStatus.rejected:
        return (Colors.red, Icons.cancel_outlined, 'Отклонено');
    }
  }
}

// ─── Пустой экран ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Вы ещё не подавали заявок',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Назад'),
          ),
        ],
      ),
    );
  }
}
