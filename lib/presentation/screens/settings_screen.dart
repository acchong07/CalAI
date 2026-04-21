import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart' show AppRoutes;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigateToOnboarding(BuildContext context) {
    //context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Edit User Information'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => _navigateToOnboarding(context),
          ),
        ],
      ),
    );
  }
}
