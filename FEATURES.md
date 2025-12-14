# Features Documentation

## ✅ Feature 1: Registration

### Описание
Регистрация новых пользователей с сохранением в Google Sheets.

### Функциональность
- Форма с полями: Полное имя, Группа
- Валидация полей (мин. 3 символа для имени)
- Сохранение в Google Sheets "Registration"
- Success dialog после регистрации
- Автоматический переход на Main Page

### Файлы
```
lib/features/registration/
├── domain/
│   ├── entities/user.dart
│   ├── repositories/registration_repository.dart
│   └── usecases/register_user_usecase.dart
├── data/
│   ├── models/user_model.dart
│   └── repositories/registration_repository_impl.dart
└── presentation/
    ├── pages/registration_page.dart
    ├── widgets/registration_form.dart
    └── providers/registration_provider.dart
```

### Google Sheets структура
**Лист: "Registration"**
| Full Name | Study Group | Registration Date |
|-----------|-------------|-------------------|
| Иванов И. | ИС-21      | 2024-01-15...     |

---

## ✅ Feature 2: Goals (Цели сбора)

### Описание
Отображение целей fundraising с прогрессом и дедлайнами.

### Функциональность
- Загрузка целей из Google Sheets
- Вычисление прогресса (процент выполнения)
- Отображение дней до дедлайна
- Статусы: В процессе / Выполнено / Истёк
- Сортировка по дедлайну (ближайшие первые)

### Computed Properties в Goal Entity
```dart
double get progress           // 0.0 to 1.0
double get remainingAmount    // Сколько ещё нужно
bool get isCompleted          // Достигнута ли цель
int get daysRemaining         // Дней до дедлайна
bool get isExpired            // Истёк ли дедлайн
```

### Файлы
```
lib/features/goals/
├── domain/
│   ├── entities/goal.dart
│   ├── repositories/goals_repository.dart
│   └── usecases/
│       ├── get_goals_usecase.dart
│       └── get_total_collected_usecase.dart
├── data/
│   ├── models/goal_model.dart
│   └── repositories/goals_repository_impl.dart
└── presentation/
    ├── pages/main_page.dart
    ├── widgets/
    │   ├── goal_card.dart
    │   └── total_amount_card.dart
    └── providers/goals_provider.dart
```

### Google Sheets структура
**Лист: "Goals"**
| Goal Name | Target Amount | Current Amount | Deadline | Description |
|-----------|--------------|----------------|----------|-------------|
| Новые ПК  | 500000       | 125000        | 2024-12-31 | Покупка... |

**Лист: "Donations"** (для подсчета total)
| Full Name | Study Group | Amount | Date | Message |
|-----------|-------------|--------|------|---------|
| Иванов И. | ИС-21      | 5000   | 2024-01-20... | Помощь |

---

## ✅ Feature 3: Main Page

### Описание
Главная страница приложения с отображением общей суммы и целей.

### Функциональность
- **Total Amount Card**: градиентная карточка с общей суммой
- **Goals List**: список всех целей с прогресс-барами
- **Pull-to-refresh**: обновление данных жестом
- **Floating Action Button**: кнопка "Помочь" (переход к донатам)
- **Empty state**: когда нет целей
- **Error handling**: красивое отображение ошибок
- **Auto-load**: данные загружаются при открытии

### UI Components

#### TotalAmountCard
- Градиентный фон с primary color
- Иконка кошелька
- Крупный текст суммы
- "Спасибо всем донорам!" badge

#### GoalCard
- Название цели и описание
- Прогресс-бар с цветом по прогрессу:
  - Серый: < 50%
  - Оранжевый: 50-75%
  - Синий: 75-99%
  - Зелёный: 100%
- Собранная и целевая сумма
- Процент выполнения
- Дни до дедлайна
- Статус badges (Выполнено/Истёк)

### Навигация
- Entry point: после регистрации
- Exit point: Floating button → Donation page (TODO)

---

## 🚧 Feature 4: Donation (Скоро)

### Планируемая функциональность
- Форма для пожертвования
- Поля: Сумма, Сообщение (опционально)
- Запись в Google Sheets "Donations"
- Обновление "Current Amount" в Goals
- Success confirmation с анимацией
- Возврат на Main Page с обновленными данными

---

## 🚧 Feature 5: Journal (Скоро)

### Планируемая функциональность
- Список всех пожертвований
- Фильтры: по дате, пользователю, сумме
- Сортировка
- Карточки донатов с сообщениями
- Статистика

---

## 🚧 Feature 6: Expenses (Скоро)

### Планируемая функциональность
- Список расходов колледжа
- Категории
- Ссылки на чеки
- Общая сумма расходов
- Прозрачность использования средств

---

## 🎨 UI/UX Highlights

### Material Design 3
- Использование `useMaterial3: true`
- ColorScheme from seed (blue)
- Elevated buttons с правильными стилями
- Input decoration theme

### Typography
- Clear hierarchy (headline/title/body)
- Bold для важной информации
- Grey для secondary text

### Colors
- Primary: Blue (seed color)
- Success: Green
- Warning: Orange
- Error: Red
- Neutral: Grey shades

### Spacing
- Consistent padding (8, 12, 16, 24)
- Border radius (8, 12, 16, 20)
- Proper margins between elements

### Feedback
- Loading indicators
- Error messages with icons
- Success dialogs
- Snackbars for quick info

---

## 🔧 Technical Stack

- **Flutter**: 3.0+
- **Dart**: 3.0+
- **State Management**: Riverpod 2.4.9
- **Backend**: Google Sheets API
- **Authentication**: Service Account
- **Formatting**: intl package
- **Architecture**: Clean Architecture

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  googleapis: ^11.4.0
  googleapis_auth: ^1.4.1
  http: ^1.1.0
  intl: ^0.18.1
```

---

## 🎯 User Flow

```
1. Открывает приложение
2. Видит Registration Page
3. Заполняет форму (имя + группа)
4. Нажимает "Зарегистрироваться"
5. Данные сохраняются в Google Sheets
6. Видит Success Dialog
7. Нажимает "Продолжить"
8. Переходит на Main Page
9. Видит Total Amount Card
10. Видит список целей с прогрессом
11. Pull-to-refresh для обновления
12. Нажимает FAB "Помочь" → Donation Page (TODO)
```

---

## 📝 Notes for Developers

### Adding New Features
1. Создайте папку в `lib/features/`
2. Следуйте Clean Architecture (domain/data/presentation)
3. Создайте providers в Riverpod
4. Подключите к Google Sheets Service
5. Добавьте навигацию

### Google Sheets Tips
- Всегда проверяйте имена листов (case-sensitive!)
- Первая строка = заголовки
- Индексы колонок начинаются с 0
- Используйте `calculateColumnSum` для сумм
- Обрабатывайте пустые ячейки

### State Management Pattern
```dart
1. Create State class (isLoading, data, error)
2. Create Notifier extending StateNotifier
3. Create Provider for repository
4. Create Provider for use cases
5. Create StateNotifierProvider
6. Use ref.watch() in widgets
7. Use ref.read().notifier for actions
```

---

## 🚀 Ready to Continue!

Следующий шаг: **Donation Feature** 🎯

Готов начать разработку прямо сейчас!

