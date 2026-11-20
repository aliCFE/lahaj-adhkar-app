import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Dark/light mode switch, added to every screen's AppBar actions so it's
/// reachable from anywhere instead of being buried inside Settings.
class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return IconButton(
      tooltip: appState.darkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
      icon: Icon(appState.darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => appState.setDarkMode(!appState.darkMode),
    );
  }
}
