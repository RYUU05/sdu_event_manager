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

  _buildLangSection(BuildContext context) {}

  _buildLogoutSection(BuildContext context) {}
}
