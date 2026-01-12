import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/characters_provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharactersProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final t = (String text) => TranslationService.translate(text, settings.language);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Text(
                t('Filters'),
                style: TextStyle(
                  color: settings.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (provider.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
                  child: Text(
                    t('Clear'),
                    style: TextStyle(color: settings.themeColor),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.close, color: settings.textSecondaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Статус
          Text(
            t('Status'),
            style: TextStyle(
              color: settings.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _FilterChips(
            options: ['Alive', 'Dead', 'unknown'],
            selected: provider.statusFilter,
            onSelected: (value) => provider.setStatusFilter(value),
            settings: settings,
          ),
          const SizedBox(height: 20),

          // Вид
          Text(
            t('Species'),
            style: TextStyle(
              color: settings.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _FilterChips(
            options: ['Human', 'Alien', 'Humanoid', 'Robot', 'Animal', 'Cronenberg', 'Mythological Creature'],
            selected: provider.speciesFilter,
            onSelected: (value) => provider.setSpeciesFilter(value),
            settings: settings,
          ),
          const SizedBox(height: 20),

          // Пол
          Text(
            t('Gender'),
            style: TextStyle(
              color: settings.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _FilterChips(
            options: ['Male', 'Female', 'Genderless', 'unknown'],
            selected: provider.genderFilter,
            onSelected: (value) => provider.setGenderFilter(value),
            settings: settings,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Function(String) onSelected;
  final SettingsProvider settings;

  const _FilterChips({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        final t = (String text) => TranslationService.translate(text, settings.language);

        return GestureDetector(
          onTap: () => onSelected(isSelected ? '' : option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? settings.themeColor.withOpacity(0.2) 
                  : settings.isDark 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? settings.themeColor 
                    : settings.isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Text(
              t(option),
              style: TextStyle(
                color: isSelected ? settings.themeColor : settings.textSecondaryColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}