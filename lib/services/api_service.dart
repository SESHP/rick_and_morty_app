import 'package:dio/dio.dart';
import '../models/character.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://rickandmortyapi.com/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Загрузка страницы персонажей
  Future<List<Character>> getCharacters(int page) async {
    try {
      final response = await _dio.get('/character', queryParameters: {
        'page': page,
      });

      final List<dynamic> results = response.data['results'];
      return results.map((json) => Character.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки персонажей: $e');
    }
  }
}