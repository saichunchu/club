import 'package:dio/dio.dart';
import '../models/experience_model.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Experience>> fetchExperiences() async {
    try {
      final resp = await _dio.get(
        'https://staging.chamberofsecrets.8club.co/v1/experiences?active=true',
        options: Options(responseType: ResponseType.json),
      );
      final data = resp.data['data']['experiences'] as List<dynamic>;
      return data.map((e) => Experience.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
