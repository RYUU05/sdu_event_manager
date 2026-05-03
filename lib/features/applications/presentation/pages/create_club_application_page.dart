import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../bloc/club_application_bloc.dart';

/// Страница подачи заявки на создание клуба (только для студентов)
@RoutePage()
class CreateClubApplicationPage extends StatefulWidget {
  const CreateClubApplicationPage({super.key});

  @override
  State<CreateClubApplicationPage> createState() =>
      _CreateClubApplicationPageState();
}

class _CreateClubApplicationPageState
    extends State<CreateClubApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _clubNameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedCategory = 'Наука';

  final _categories = [
    'Наука',
    'Спорт',
    'Творчество',
    'IT',
    'Волонтёрство',
    'Культура',
    'Другое',
  ];

  @override
  void dispose() {
    _clubNameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, ClubApplicationBloc bloc) {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    bloc.add(SubmitApplicationEvent(
      userId: authState.user.id,
      userName: authState.user.name,
      clubName: _clubNameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<ClubApplicationBloc>();

    return BlocProvider.value(
      value: bloc,
      child: BlocListener<ClubApplicationBloc, ClubApplicationState>(
        listener: (context, state) {
          if (state is ApplicationSuccess) {
            _showSuccessDialog(context);
          } else if (state is ApplicationError) {
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
            title: const Text('Заявка на клуб'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Заголовок секции
                  _SectionHeader(
                    icon: Icons.groups_outlined,
                    title: 'Информация о клубе',
                  ),
                  const SizedBox(height: 16),

                  // Название клуба
                  TextFormField(
                    controller: _clubNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Название клуба',
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Описание клуба',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.description_outlined),
                      ),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().length < 20)
                            ? 'Минимум 20 символов'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Категория
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Категория',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v ?? _selectedCategory),
                  ),
                  const SizedBox(height: 12),

                  // Инфо-блок
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.schedule_outlined,
                            color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Заявка будет рассмотрена администратором SDULife в течение нескольких дней.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Кнопка отправки
                  BlocBuilder<ClubApplicationBloc, ClubApplicationState>(
                    builder: (context, state) {
                      final loading = state is ApplicationLoading;
                      return FilledButton.icon(
                        onPressed: loading ? null : () => _submit(context, bloc),
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_outlined),
                        label: const Text('Отправить заявку'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Заявка отправлена!'),
        content: const Text(
          'Ваша заявка принята и находится на рассмотрении. '
          'Мы уведомим вас, когда администратор примет решение.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // закрыть диалог
              context.router.maybePop(); // вернуться назад
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}

// ─── Вспомогательный виджет ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
