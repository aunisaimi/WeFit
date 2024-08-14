import 'package:diet_app/common/box.dart';
import 'package:diet_app/screen/Theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/screen/main_tab/main_tab_view.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Tab View'),
        actions: [
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Hello, world!'),
      ),
    );
  }
}
