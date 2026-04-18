import 'package:auto_route/auto_route.dart';
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
    settingsBloc = SettingsBloc(repository);
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

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return BlocProvider(
      create: (_) => settingsBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
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
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(state.currentLang),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      languageProvider.toggleLanguage();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
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
