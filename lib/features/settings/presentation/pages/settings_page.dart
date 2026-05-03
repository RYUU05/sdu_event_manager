import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../bloc/settings_bloc.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsBloc settingsBloc;
  final _interestsCtrl = TextEditingController();
  bool _savingInterests = false;

  List<String> _parseInterests(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _saveInterests(BuildContext context) async {
    if (_savingInterests) return;
    setState(() => _savingInterests = true);
    try {
      final repo = sl<AuthRepository>();
      final list = _parseInterests(_interestsCtrl.text);
      await repo.updateInterests(list);
      if (context.mounted) {
        context.read<AuthBloc>().add(RefreshProfileRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.localization.interestsSaved)),
        );
      }
    } finally {
      if (mounted) setState(() => _savingInterests = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Используем getIt из injection.dart
    settingsBloc = sl<SettingsBloc>(); 
    settingsBloc.add(LoadSettingsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = sl<AuthBloc>().currentUser;
      if (u != null && u.role == UserRole.student && u.interests.isNotEmpty) {
        _interestsCtrl.text = u.interests.join(', ');
      }
    });
  }

  @override
  void dispose() {
    _interestsCtrl.dispose();
    settingsBloc.close();
    super.dispose();
  }

  void logout() {
    context.read<AuthBloc>().add(LogoutRequested());
    context.router.replace(const LoginRoute());
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider provider, String currentLang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.localization.selectingLang),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: currentLang == 'en' ? const Icon(Icons.check) : null,
              onTap: () {
                provider.changeLanguage('en');
                settingsBloc.add(LanguageEvent('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Русский'),
              trailing: currentLang == 'ru' ? const Icon(Icons.check) : null,
              onTap: () {
                provider.changeLanguage('ru');
                settingsBloc.add(LanguageEvent('ru'));
                Navigator.pop(ctx);
              },
            ), // <-- Проверь, чтобы тут была эта запятая и скобка
            ListTile(
              title: const Text('Қазақша'),
              trailing: currentLang == 'kk' ? const Icon(Icons.check) : null,
              onTap: () {
                provider.changeLanguage('kk');
                settingsBloc.add(LanguageEvent('kk'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return BlocProvider.value( // Используем .value, так как блок уже создан
      value: settingsBloc,
      child: Scaffold(
        appBar: AppBar(title: Text(context.localization.settings)),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is SettingsLoaded) {
              final authState = context.watch<AuthBloc>().state;
              final showInterests = authState is Authenticated &&
                  authState.user.role == UserRole.student;
              return ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle_rounded),
                    title: Text(context.localization.account),
                    subtitle: Text(state.currentUser),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(state.currentRole),
                    ),
                  ),
                  if (showInterests) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.localization.interestsLabel,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _interestsCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: context.localization.interestsHint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed:
                                _savingInterests ? null : () => _saveInterests(context),
                            child: Text(context.localization.save),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.localization.language),
                    subtitle: Text(
                      languageProvider.locale.languageCode == 'en' 
                          ? 'English' 
                          : languageProvider.locale.languageCode == 'kk'
                              ? 'Қазақша'
                              : 'Русский',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(
                      context,
                      languageProvider,
                      languageProvider.locale.languageCode,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      context.localization.logout,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: logout,
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}