import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Selected experience IDs
final selectedIdsProvider = StateProvider<List<int>>((ref) => []);

// Text from experience selection (max 250)
final experienceTextProvider = StateProvider<String>((ref) => '');

// Onboarding question text (max 600)
final onboardingTextProvider = StateProvider<String>((ref) => '');

// Audio file path (nullable)
final recordedAudioPathProvider = StateProvider<String?>((ref) => null);

// Video file path (nullable)
final recordedVideoPathProvider = StateProvider<String?>((ref) => null);



