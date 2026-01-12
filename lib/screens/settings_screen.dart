import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final t = (String text) => TranslationService.translate(text, settings.language);
        
        return Scaffold(
          backgroundColor: settings.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Text(
                      t('Settings'),
                      style: TextStyle(
                        color: settings.textColor,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  
                  // Тема
                  _SectionTitle(title: t('Appearance'), settings: settings),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ThemeSelector(settings: settings, t: t),
                  ),
                  const SizedBox(height: 24),
                  
                  // Цвет темы
                  _SectionTitle(title: t('Theme color'), settings: settings),
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: SettingsProvider.themeColors.length,
                      itemBuilder: (context, index) {
                        final entry = SettingsProvider.themeColors.entries.elementAt(index);
                        final isSelected = settings.colorKey == entry.key;
                        
                        return GestureDetector(
                          onTap: () => settings.setColor(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? settings.textColor : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: entry.value.withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 24)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Язык
                  _SectionTitle(title: t('Language'), settings: settings),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _LanguageOption(
                          title: t('Russian'),
                          subtitle: 'Русский',
                          isSelected: settings.language == 'ru',
                          onTap: () => settings.setLanguage('ru'),
                          settings: settings,
                        ),
                        const SizedBox(height: 8),
                        _LanguageOption(
                          title: t('English'),
                          subtitle: 'English',
                          isSelected: settings.language == 'en',
                          onTap: () => settings.setLanguage('en'),
                          settings: settings,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final SettingsProvider settings;

  const _SectionTitle({required this.title, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          color: settings.textSecondaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final SettingsProvider settings;
  final String Function(String) t;

  const _ThemeSelector({required this.settings, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: settings.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: t('Dark theme'),
            isSelected: settings.isDark,
            onTap: () => settings.setDarkMode(true),
            settings: settings,
          ),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: t('Light theme'),
            isSelected: !settings.isDark,
            onTap: () => settings.setDarkMode(false),
            settings: settings,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final SettingsProvider settings;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? settings.themeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : settings.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : settings.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final SettingsProvider settings;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? settings.themeColor.withOpacity(0.15) 
              : settings.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? settings.themeColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: settings.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: settings.textTertiaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0,
              child: Icon(Icons.check_circle, color: settings.themeColor, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}