import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/characters_provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';
import '../widgets/character_card.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CharactersProvider>().loadCharacters();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<CharactersProvider>().loadCharacters();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FilterSheet(),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<CharactersProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final t = (String text) => TranslationService.translate(text, settings.language);

    return Scaffold(
      backgroundColor: settings.isDark ? Colors.black : const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и кнопки
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  if (!_showSearch)
                    Expanded(
                      child: Text(
                        t('Characters'),
                        style: TextStyle(
                          color: settings.isDark ? Colors.white : Colors.black,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  if (_showSearch)
                    Expanded(
                      child: _SearchField(
                        controller: _searchController,
                        hintText: t('Search by name...'),
                        color: settings.themeColor,
                        isDark: settings.isDark,
                        onChanged: (value) {
                          context.read<CharactersProvider>().setSearchQuery(value);
                        },
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _showSearch ? Icons.close : Icons.search,
                      color: settings.isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) {
                          _searchController.clear();
                          context.read<CharactersProvider>().setSearchQuery('');
                        }
                      });
                    },
                  ),
                  Consumer<CharactersProvider>(
                    builder: (context, provider, child) {
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: provider.hasActiveFilters
                                  ? settings.themeColor
                                  : settings.isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: _showFilters,
                          ),
                          if (provider.hasActiveFilters)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: settings.themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Контент
            Expanded(
              child: Consumer<CharactersProvider>(
                builder: (context, provider, child) {
                  // Ошибка
                  if (provider.error != null && provider.characters.isEmpty) {
                    return ErrorRetryWidget(
                      error: provider.error!,
                      onRetry: () => provider.retry(),
                    );
                  }

                  // Начальная загрузка — shimmer
                  if (provider.isInitialLoad && provider.characters.isEmpty) {
                    return const SkeletonGrid();
                  }

                  // Пустой результат фильтрации
                  if (provider.characters.isEmpty && provider.hasActiveFilters) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: settings.isDark 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('No results'),
                            style: TextStyle(
                              color: settings.isDark 
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('Try changing filters'),
                            style: TextStyle(
                              color: settings.isDark 
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => provider.clearFilters(),
                            child: Text(
                              t('Clear'),
                              style: TextStyle(color: settings.themeColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Список с pull-to-refresh
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: settings.themeColor,
                    backgroundColor: settings.isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: provider.characters.length + 1,
                      itemBuilder: (context, index) {
                        if (index == provider.characters.length) {
                          return provider.hasMore && !provider.hasActiveFilters
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: settings.themeColor,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        return CharacterCard(
                            character: provider.characters[index],
                            index: index,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color color;
  final bool isDark;
  final Function(String) onChanged;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.color,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
}