import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/characters_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DatabaseService.init();
  
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  
  runApp(MyApp(settingsProvider: settingsProvider));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  
  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharactersProvider()..loadFavorites()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          // Обновляем цвет статус бара
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarBrightness: settings.isDark ? Brightness.dark : Brightness.light,
              statusBarIconBrightness: settings.isDark ? Brightness.light : Brightness.dark,
            ),
          );
          
          return MaterialApp(
            title: 'Rick and Morty',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF2F2F7),
              colorScheme: ColorScheme.light(
                primary: settings.themeColor,
                secondary: settings.themeColor,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              colorScheme: ColorScheme.dark(
                primary: settings.themeColor,
                secondary: settings.themeColor,
              ),
              useMaterial3: true,
            ),
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final t = (String text) => TranslationService.translate(text, settings.language);
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: settings.isDark 
                  ? const Color(0xFF2C2C2E) 
                  : Colors.black.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: settings.isDark ? const Color(0xFF1C1C1E) : Colors.white,
          selectedItemColor: settings.themeColor,
          unselectedItemColor: settings.isDark ? Colors.white38 : Colors.black38,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline_rounded),
              activeIcon: const Icon(Icons.people_rounded),
              label: t('Characters'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star_outline_rounded),
              activeIcon: const Icon(Icons.star_rounded),
              label: t('Favorites'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: t('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}