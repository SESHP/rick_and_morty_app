import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/characters_provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';
import '../widgets/character_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final t = (String text) => TranslationService.translate(text, settings.language);

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t('Favorites'),
                      style: TextStyle(
                        color: settings.textColor,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.sort_rounded,
                      color: settings.themeColor,
                    ),
                    color: settings.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      setState(() => _sortBy = value);
                      context.read<CharactersProvider>().sortFavorites(value);
                    },
                    itemBuilder: (context) => [
                      _buildMenuItem('name', t('By name'), settings),
                      _buildMenuItem('status', t('By status'), settings),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CharactersProvider>(
                builder: (context, provider, child) {
                  if (provider.favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_outline_rounded,
                            size: 64,
                            color: settings.textTertiaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('No favorites'),
                            style: TextStyle(
                              color: settings.textSecondaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('Add characters by tapping ★'),
                            style: TextStyle(
                              color: settings.textTertiaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.favorites.length,
                    itemBuilder: (context, index) {
                      return CharacterCard(
                        character: provider.favorites[index],
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, SettingsProvider settings) {
    final isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            Icon(Icons.check, color: settings.themeColor, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: settings.textColor),
          ),
        ],
      ),
    );
  }
}