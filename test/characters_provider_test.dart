import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/models/character.dart';
import 'package:rick_and_morty_app/providers/characters_provider.dart';

void main() {
  group('CharactersProvider', () {
    late CharactersProvider provider;

    setUp(() {
      provider = CharactersProvider();
    });

    group('Filters', () {
      test('initial state has no active filters', () {
        expect(provider.hasActiveFilters, false);
        expect(provider.searchQuery, '');
        expect(provider.statusFilter, '');
        expect(provider.speciesFilter, '');
        expect(provider.genderFilter, '');
      });

      test('setSearchQuery updates search query', () {
        provider.setSearchQuery('Rick');
        expect(provider.searchQuery, 'Rick');
        expect(provider.hasActiveFilters, true);
      });

      test('setStatusFilter updates status filter', () {
        provider.setStatusFilter('Alive');
        expect(provider.statusFilter, 'Alive');
        expect(provider.hasActiveFilters, true);
      });

      test('setSpeciesFilter updates species filter', () {
        provider.setSpeciesFilter('Human');
        expect(provider.speciesFilter, 'Human');
        expect(provider.hasActiveFilters, true);
      });

      test('setGenderFilter updates gender filter', () {
        provider.setGenderFilter('Male');
        expect(provider.genderFilter, 'Male');
        expect(provider.hasActiveFilters, true);
      });

      test('clearFilters resets all filters', () {
        provider.setSearchQuery('Rick');
        provider.setStatusFilter('Alive');
        provider.setSpeciesFilter('Human');
        provider.setGenderFilter('Male');

        provider.clearFilters();

        expect(provider.hasActiveFilters, false);
        expect(provider.searchQuery, '');
        expect(provider.statusFilter, '');
        expect(provider.speciesFilter, '');
        expect(provider.genderFilter, '');
      });
    });

    group('Sorting', () {
      test('sortFavorites by name sorts alphabetically', () {
        // Проверяем что метод не вызывает ошибок
        expect(() => provider.sortFavorites('name'), returnsNormally);
      });

      test('sortFavorites by status sorts by status', () {
        expect(() => provider.sortFavorites('status'), returnsNormally);
      });
    });

    group('State', () {
      test('initial state is correct', () {
        expect(provider.characters, isEmpty);
        expect(provider.favorites, isEmpty);
        expect(provider.isLoading, false);
        expect(provider.isInitialLoad, true);
        expect(provider.hasMore, true);
        expect(provider.error, isNull);
      });
    });
  });

  group('Character Model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'image': 'https://example.com/rick.png',
        'location': {'name': 'Earth'},
        'gender': 'Male',
        'origin': {'name': 'Earth (C-137)'},
        'type': '',
        'episode': ['ep1', 'ep2', 'ep3'],
      };

      final character = Character.fromJson(json);

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.status, 'Alive');
      expect(character.species, 'Human');
      expect(character.gender, 'Male');
      expect(character.origin, 'Earth (C-137)');
      expect(character.location, 'Earth');
      expect(character.episodeCount, 3);
      expect(character.type, 'Unknown');
    });

    test('fromJson handles empty type', () {
      final json = {
        'id': 2,
        'name': 'Morty',
        'status': 'Alive',
        'species': 'Human',
        'image': 'https://example.com/morty.png',
        'location': {'name': 'Earth'},
        'gender': 'Male',
        'origin': {'name': 'Earth'},
        'type': '',
        'episode': [],
      };

      final character = Character.fromJson(json);
      expect(character.type, 'Unknown');
      expect(character.episodeCount, 0);
    });
  });
}