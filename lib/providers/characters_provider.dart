import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class CharactersProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();

  List<Character> _characters = [];
  List<Character> _favorites = [];
  bool _isLoading = false;
  bool _isInitialLoad = true;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _error;

  // Фильтры
  String _searchQuery = '';
  String _statusFilter = '';
  String _speciesFilter = '';
  String _genderFilter = '';

  List<Character> get characters {
    return _applyFilters(_characters);
  }

  List<Character> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get isInitialLoad => _isInitialLoad;
  bool get hasMore => _hasMore;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get speciesFilter => _speciesFilter;
  String get genderFilter => _genderFilter;

  List<Character> _applyFilters(List<Character> list) {
    return list.where((char) {
      if (_searchQuery.isNotEmpty) {
        if (!char.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_statusFilter.isNotEmpty && char.status != _statusFilter) {
        return false;
      }
      if (_speciesFilter.isNotEmpty && char.species != _speciesFilter) {
        return false;
      }
      if (_genderFilter.isNotEmpty && char.gender != _genderFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSpeciesFilter(String species) {
    _speciesFilter = species;
    notifyListeners();
  }

  void setGenderFilter(String gender) {
    _genderFilter = gender;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = '';
    _speciesFilter = '';
    _genderFilter = '';
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _statusFilter.isNotEmpty ||
        _speciesFilter.isNotEmpty ||
        _genderFilter.isNotEmpty;
  }

  // Загрузка персонажей
  Future<void> loadCharacters({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _characters = [];
      _error = null;
      _isInitialLoad = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCharacters = await _apiService.getCharacters(_currentPage);

      if (newCharacters.isEmpty) {
        _hasMore = false;
      } else {
        _characters.addAll(newCharacters);
        _currentPage++;
        await _databaseService.cacheCharacters(newCharacters);
      }
      _isInitialLoad = false;
    } catch (e) {
      if (_characters.isEmpty) {
        final cached = _databaseService.getCachedCharacters();
        if (cached.isNotEmpty) {
          _characters = cached;
          _isInitialLoad = false;
        } else {
          _error = e.toString();
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Pull-to-refresh
  Future<void> refresh() async {
    await loadCharacters(refresh: true);
  }

  // Повторная попытка при ошибке
  Future<void> retry() async {
    _error = null;
    _isInitialLoad = true;
    notifyListeners();
    await loadCharacters();
  }

  void loadFavorites() {
    _favorites = _databaseService.getFavorites();
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _databaseService.isFavorite(id);
  }

  Future<void> toggleFavorite(Character character) async {
    if (isFavorite(character.id)) {
      await _databaseService.removeFromFavorites(character.id);
    } else {
      await _databaseService.addToFavorites(character);
    }
    loadFavorites();
    notifyListeners();
  }

  void sortFavorites(String by) {
    switch (by) {
      case 'name':
        _favorites.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'status':
        _favorites.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
    notifyListeners();
  }
}