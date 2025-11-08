import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/experience_selection_screen.dart';

void main() {
  runApp(const ProviderScope(child: HotspotOnboardingApp()));
}

class HotspotOnboardingApp extends StatelessWidget {
  const HotspotOnboardingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotspot Onboarding',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const ExperienceSelectionScreen(),
    );
  }
}
