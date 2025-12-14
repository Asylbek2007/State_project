# Navigation & Structure - Complete Guide

## ✅ Реализовано (Приоритет 2)

### Архитектура навигации

```
App Launch → Splash Screen
              ↓
        Token Check
       ↙           ↘
   Valid?         Not Valid?
      ↓               ↓
  HomePage      Registration
  (3 tabs)           ↓
                 Generate Token
                     ↓
                  HomePage
```

---

## 🏠 HomePage - Central Hub

**Файл:** `lib/features/home/presentation/pages/home_page.dart`

### BottomNavigationBar с 3 табами:

1. **Profile** (левая) - Профиль пользователя
2. **Main** (центр) - Главная страница (default)
3. **Community** (правая) - Сообщество

### Особенности:
- `IndexedStack` для сохранения состояния вкладок
- `initialIndex` parameter для выбора стартовой вкладки
- Sky-blue selected color
- Material Design 3 стиль

---

## 👤 Tab 1: Profile

**Файл:** `lib/features/profile/presentation/pages/profile_page.dart`

### Секции:

#### 1. User Header Card (градиентная)
- Avatar (круглая иконка)
- Имя пользователя
- Группа (badge)
- Sky-blue gradient background

#### 2. Stats Section
- **Помощь:** Количество донатов (пока 0)
- **Достижения:** Бейджи (пока 0)

#### 3. Settings Section
- ✏️ Редактировать профиль (TODO)
- 🔔 Уведомления (toggle)
- ❓ Помощь и поддержка
- ℹ️ О приложении (версия 1.0.0)

#### 4. Logout Button
- Красная outlined button
- Confirmation dialog
- Очистка token storage
- Навигация → Splash → Registration

---

## 🏠 Tab 2: Main (Goals)

**Файл:** `lib/features/goals/presentation/pages/goals_page.dart`

### Контент:

#### 1. Total Amount Card
- Градиентная карточка
- Показывает общую сумму собранных средств
- Иконка кошелька

#### 2. Goals List
- Карточки целей с прогрессом
- Progress bars с анимацией
- Процент выполнения
- Дедлайны

#### 3. FloatingActionButton "Помочь"
- Навигация → Donation Page
- Auto-refresh после доната

#### 4. AppBar Actions
- 📜 Журнал (History) → Journal Page
- 🧾 Расходы (Receipt) → Expenses Page
- 🔄 Refresh

---

## 🌟 Tab 3: Community (Impact Wall)

**Файл:** `lib/features/community/presentation/pages/community_page.dart`

### Секции:

#### 1. Hero Section
- Градиентная карточка
- "Вместе мы сила!"
- Мотивационный текст

#### 2. Community Stats (3 карточки)
- 💙 Пожертвований (total count)
- 👥 Доноров (unique donors)
- 💬 Сообщений (donations with messages)

#### 3. Top Donors Leaderboard 🏆
- **#1:** 🥇 Золотая карточка
- **#2:** 🥈 Серебряная карточка
- **#3:** 🥉 Бронзовая карточка
- Имя + общая сумма донатов
- Цветные borders и тени

#### 4. Impact Stories (Истории помощи)
- Последние 5 донатов с сообщениями
- Карточки с:
  - Аватар донора
  - Имя и дата
  - Сумма (зелёный badge)
  - Сообщение в quote box

---

## 🎨 UI/UX Features

### Sky-blue Theme в действии:
- **BottomNav:** White background, sky-blue selected
- **Cards:** White с легкими тенями
- **Gradients:** Sky-blue → Accent blue
- **Icons:** Sky-blue color
- **Badges:** Цветные (gold/silver/bronze)

### Spacing & Layout:
- Consistent 8/12/16/24 spacing tokens
- 12/16 border radius
- Smooth shadows
- Clean white background

### Interactive Elements:
- Tap feedback
- Pull-to-refresh на всех вкладках
- Loading states
- Empty states

---

## 🔄 Navigation Flow

### Основной flow:
```
Splash → Home (Main tab) → Tabs switching
                            ↓
                    Profile | Main | Community
                            ↓
                    Остаются в Home scaffold
```

### Secondary navigation (push):
```
Main Tab → [FAB] → Donation Page → Back + Refresh
        → [History] → Journal Page → Back
        → [Receipt] → Expenses Page → Back
```

### Logout flow:
```
Profile → Logout button → Confirmation dialog → Clear token → Splash → Registration
```

---

## 📦 Новые файлы

```
lib/features/
├── home/
│   └── presentation/
│       └── pages/
│           └── home_page.dart         ← 🆕 Central hub с tabs
├── profile/
│   └── presentation/
│       └── pages/
│           └── profile_page.dart      ← 🆕 User profile + settings
├── community/
│   └── presentation/
│       └── pages/
│           └── community_page.dart    ← 🆕 Impact Wall
└── goals/
    └── presentation/
        └── pages/
            ├── goals_page.dart         ← ✏️ Refactored (was main_page.dart)
            └── main_page.dart          ← ❌ DELETED
```

---

## 🔌 Интеграция

### Splash Page:
```dart
// Теперь навигирует на HomePage вместо MainPage
if (isAuth) {
  Navigator.pushReplacement(
    MaterialPageRoute(
      builder: (_) => HomePage(
        userName: userData['userName']!,
        userGroup: userData['userGroup']!,
        initialIndex: 1, // Start at Main tab
      ),
    ),
  );
}
```

### Registration Page:
```dart
// После регистрации → HomePage
Navigator.pushReplacement(
  MaterialPageRoute(
    builder: (_) => HomePage(
      userName: user.fullName,
      userGroup: user.studyGroup,
      initialIndex: 1,
    ),
  ),
);
```

---

## 📱 User Experience

### Первый запуск:
1. Splash (2 сек + animation)
2. Registration
3. Token saved
4. **HomePage opens → Main tab**

### Повторный запуск (keep-logged):
1. Splash
2. Token valid
3. **HomePage opens → Main tab** (без Registration!)

### Навигация между вкладками:
- Тап на иконку → мгновенное переключение
- Состояние каждой вкладки сохраняется (IndexedStack)
- Scroll position preserved
- No rebuilds при переключении

### Logout:
1. Profile tab
2. "Выйти" button
3. Confirmation dialog
4. Token cleared
5. Splash → Registration

---

## ✨ Highlights

### Profile Tab:
- ✅ Beautiful gradient header
- ✅ Stats cards (готовы для будущих данных)
- ✅ Settings list
- ✅ Working logout с confirmation
- ✅ About dialog

### Community Tab:
- ✅ Hero motivational section
- ✅ Real-time stats (count, unique donors, messages)
- ✅ Top 3 donors leaderboard с medals 🥇🥈🥉
- ✅ Impact stories с quotes
- ✅ Pull-to-refresh

### Goals Tab:
- ✅ Integrated в новый navigation
- ✅ Все функции сохранены
- ✅ FAB "Помочь" работает
- ✅ AppBar actions (History, Expenses, Refresh)

---

## 🚀 Готово к использованию!

Все 3 таба полностью функциональны и интегрированы с:
- ✅ Sky-blue theme
- ✅ Token authentication
- ✅ Google Sheets data
- ✅ Clean Architecture
- ✅ Material Design 3

---

## ⏭️ Следующие улучшения (опционально):

### Profile Tab:
- Edit profile flow
- User avatar upload
- Donation history

### Community Tab:
- Pagination для stories
- Filter по датам
- Achievements system

### Navigation:
- Deep links
- Share functionality
- Notifications

---

**Navigation & Structure — COMPLETE! 🎉**

