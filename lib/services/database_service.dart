import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';

class DatabaseService {
  static const String _favoritesBox = 'favorites';
  static const String _cacheBox = 'characters_cache';

  // Инициализация базы
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CharacterAdapter());
    await Hive.openBox<Character>(_favoritesBox);
    await Hive.openBox<Character>(_cacheBox);
  }

  // === ИЗБРАННОЕ ===

  Box<Character> get _favorites => Hive.box<Character>(_favoritesBox);

  List<Character> getFavorites() {
    return _favorites.values.toList();
  }

  bool isFavorite(int id) {
    return _favorites.containsKey(id);
  }

  Future<void> addToFavorites(Character character) async {
    await _favorites.put(character.id, character);
  }

  Future<void> removeFromFavorites(int id) async {
    await _favorites.delete(id);
  }

  // === КЭШ ===

  Box<Character> get _cache => Hive.box<Character>(_cacheBox);

  List<Character> getCachedCharacters() {
    return _cache.values.toList();
  }

  Future<void> cacheCharacters(List<Character> characters) async {
    for (var char in characters) {
      await _cache.put(char.id, char);
    }
  }
}