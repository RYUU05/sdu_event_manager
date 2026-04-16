import 'package:event_manager/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class ContentWidget extends StatelessWidget {
  final String currentLang;
  final Function(String) onLangChanged;
  final VoidCallback onLogout;
  const ContentWidget({
    super.key,
    required this.currentLang,
    required this.onLangChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLangSection(context),
          SizedBox(height: 16),

          _buildLogoutSection(context),
        ],
      ),
    );
  }

  _buildLangSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text(_getLangDisplay(currentLang)),
            onTap: () => _showLang(context),
          ),
        ],
      ),
    );
  }

  _buildLogoutSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout'),
        onTap: onLogout,
      ),
    );
  }

  String _getLangDisplay(String languageCode) {
    switch (languageCode) {
      case AppConstants.english:
        return 'English';
      case AppConstants.russion:
        return 'Русский';
      default:
        return languageCode.toUpperCase();
    }
  }

  void _showLang(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select langiage'),
        content: Column(
          children: [
            _buildLangOption(context, 'Englisg', AppConstants.english),
            _buildLangOption(context, 'Русский', AppConstants.russion),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(
    BuildContext context,
    String displayName,
    String code,
  ) {
    final isSelected = code == currentLang;

    return ListTile(
      title: Text(displayName),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          onLangChanged(code);
        }
      },
    );
  }
}
