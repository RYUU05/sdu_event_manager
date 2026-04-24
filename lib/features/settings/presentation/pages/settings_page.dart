import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../../data/datasources/settings_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../bloc/settings_bloc.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsBloc settingsBloc;

  @override
  void initState() {
    super.initState();
    final dataSource = SettingsDataSource();
    final repository = SettingsRepositoryImpl(dataSource);
    settingsBloc = SettingsBloc(repository, context.read<AuthBloc>());
    settingsBloc.add(LoadSettingsEvent());
  }

  @override
  void dispose() {
    settingsBloc.close();
    super.dispose();
  }

  void logout() {
    context.read<AuthBloc>().add(LogoutRequested());
    context.router.replace(const LoginRoute());
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider provider,
    String currentLang,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: currentLang == 'en' ? const Icon(Icons.check) : null,
              onTap: () {
                provider.changeLanguage('en');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Русский'),
              trailing: currentLang == 'ru' ? const Icon(Icons.check) : null,
              onTap: () {
                provider.changeLanguage('ru');
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

    return BlocProvider(
      create: (_) => settingsBloc,
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
              return ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle_rounded),
                    title: Text(context.localization.account),
                    subtitle: Text(state.currentUser),
                    trailing: Text(state.currentRole),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.localization.language),
                    subtitle: Text(
                      state.currentLang == 'en' ? 'English' : 'Русский',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(
                      context,
                      languageProvider,
                      state.currentLang,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      context.localization.logout,
                      style: TextStyle(color: Colors.red),
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
