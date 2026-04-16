import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:event_manager/core/providers/language_provider.dart';
import 'package:event_manager/core/router/app_router.gr.dart';
import 'package:event_manager/features/settings/data/datasources/settings_data_source.dart';
import 'package:event_manager/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:event_manager/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:event_manager/features/settings/presentation/widget/loading_widget.dart';
import 'package:event_manager/features/settings/presentation/widget/error_widget.dart'
    as custom;
import 'package:event_manager/features/settings/presentation/widget/content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    _loadInitialData();
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  void _initializeBloc() {
    final dataSource = SettingsDataSource();
    final repository = SettingsRepositoryImpl(dataSource);
    _settingsBloc = SettingsBloc(repository);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _settingsBloc.add(LoadSettingsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _settingsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.localization.settings,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return switch (state) {
              SettingsLoading() => const LoadingWidget(),
              SettingsError() => custom.ErrorWidget(
                message: state.message,
                onRetry: () => _settingsBloc.add(LoadSettingsEvent()),
              ),
              SettingsLoaded() => ContentWidget(
                currentLang: state.currentLang,
                onLangChanged: _handleLanguageChange,
                onLogout: _handleLogout,
              ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  void _handleLanguageChange(String language) {
    context.read<LanguageProvider>().changeLanguage(language);
    _settingsBloc.add(LanguageEvent(language));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Language changed to $language')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(context.localization.logout),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? All your local data will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.localization.logout),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    _settingsBloc.add(LogoutEvent());

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.router.replace(const LoginRoute());
      }
    });
  }
}
