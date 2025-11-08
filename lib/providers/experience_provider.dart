import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/experience_model.dart';
import '../services/api_service.dart';

// List of Experiences (loaded from API)
final experiencesProvider = StateNotifierProvider<ExperiencesNotifier, AsyncValue<List<Experience>>>((ref) {
  return ExperiencesNotifier();
});

class ExperiencesNotifier extends StateNotifier<AsyncValue<List<Experience>>> {
  final ApiService _api = ApiService();

  ExperiencesNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final list = await _api.fetchExperiences();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
