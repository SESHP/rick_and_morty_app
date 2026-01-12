class TranslationService {
  static const Map<String, Map<String, String>> _translations = {
    // Статусы
    'Alive': {'ru': 'Живой', 'en': 'Alive'},
    'Dead': {'ru': 'Мёртв', 'en': 'Dead'},
    'unknown': {'ru': 'Неизвестно', 'en': 'Unknown'},
    
    // Пол
    'Male': {'ru': 'Мужской', 'en': 'Male'},
    'Female': {'ru': 'Женский', 'en': 'Female'},
    'Genderless': {'ru': 'Бесполый', 'en': 'Genderless'},
    
    // Виды
    'Human': {'ru': 'Человек', 'en': 'Human'},
    'Alien': {'ru': 'Пришелец', 'en': 'Alien'},
    'Humanoid': {'ru': 'Гуманоид', 'en': 'Humanoid'},
    'Poopybutthole': {'ru': 'Пупибатхол', 'en': 'Poopybutthole'},
    'Mythological Creature': {'ru': 'Мифическое существо', 'en': 'Mythological Creature'},
    'Animal': {'ru': 'Животное', 'en': 'Animal'},
    'Robot': {'ru': 'Робот', 'en': 'Robot'},
    'Cronenberg': {'ru': 'Кроненберг', 'en': 'Cronenberg'},
    'Disease': {'ru': 'Болезнь', 'en': 'Disease'},
    'Parasite': {'ru': 'Паразит', 'en': 'Parasite'},
    'Unknown': {'ru': 'Неизвестно', 'en': 'Unknown'},
    
    // UI элементы
    'Characters': {'ru': 'Персонажи', 'en': 'Characters'},
    'Favorites': {'ru': 'Избранное', 'en': 'Favorites'},
    'Settings': {'ru': 'Настройки', 'en': 'Settings'},
    'Location': {'ru': 'Локация', 'en': 'Location'},
    'Origin': {'ru': 'Происхождение', 'en': 'Origin'},
    'Type': {'ru': 'Тип', 'en': 'Type'},
    'Episodes': {'ru': 'Эпизодов', 'en': 'Episodes'},
    'No favorites': {'ru': 'Нет избранных', 'en': 'No favorites'},
    'Add characters by tapping ★': {'ru': 'Добавьте персонажей нажав ★', 'en': 'Add characters by tapping ★'},
    'No data': {'ru': 'Нет данных', 'en': 'No data'},
    'Theme color': {'ru': 'Цвет темы', 'en': 'Theme color'},
    'Language': {'ru': 'Язык', 'en': 'Language'},
    'Russian': {'ru': 'Русский', 'en': 'Russian'},
    'English': {'ru': 'Английский', 'en': 'English'},
    'By name': {'ru': 'По имени', 'en': 'By name'},
    'By status': {'ru': 'По статусу', 'en': 'By status'},
    
    // Фильтры
    'Filters': {'ru': 'Фильтры', 'en': 'Filters'},
    'Clear': {'ru': 'Сбросить', 'en': 'Clear'},
    'Status': {'ru': 'Статус', 'en': 'Status'},
    'Species': {'ru': 'Вид', 'en': 'Species'},
    'Gender': {'ru': 'Пол', 'en': 'Gender'},
    'Search': {'ru': 'Поиск', 'en': 'Search'},
    'Search by name...': {'ru': 'Поиск по имени...', 'en': 'Search by name...'},
    'No results': {'ru': 'Ничего не найдено', 'en': 'No results'},
    'Try changing filters': {'ru': 'Попробуйте изменить фильтры', 'en': 'Try changing filters'},
    
    // Ошибки
    'Connection error': {'ru': 'Ошибка соединения', 'en': 'Connection error'},
    'Failed to load data. Check your internet connection.': {
      'ru': 'Не удалось загрузить данные. Проверьте подключение к интернету.',
      'en': 'Failed to load data. Check your internet connection.'
    },
    'Retry': {'ru': 'Повторить', 'en': 'Retry'},
    
    // Темы
    'Appearance': {'ru': 'Оформление', 'en': 'Appearance'},
    'Dark theme': {'ru': 'Тёмная тема', 'en': 'Dark theme'},
    'Light theme': {'ru': 'Светлая тема', 'en': 'Light theme'},
    'System': {'ru': 'Системная', 'en': 'System'},
  };

  static String translate(String text, String language) {
    if (_translations.containsKey(text)) {
      return _translations[text]![language] ?? text;
    }
    return text;
  }
}