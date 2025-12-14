# Быстрый старт Backend

## 1. Установка зависимостей

```bash
cd backend
dart pub get
```

## 2. Настройка конфигурации

Создайте файл `.env` в папке `backend/`:

```bash
# JWT Secret (измените в продакшене!)
JWT_SECRET=your-secret-key-change-me-in-production

# Google Sheets Spreadsheet ID
SPREADSHEET_ID=1qMwgXatKVAywkdGbTQYpKV6jNzXQhbjwrduajKXlA-o

# Admin Password
ADMIN_PASSWORD=admin2024

# Service Account JSON (вставьте полный JSON ключ)
SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"inlaid-fx-473411-h6",...}

# Или используйте путь к файлу:
# SERVICE_ACCOUNT_PATH=./service_account.json
```

**Или** создайте файл `service_account.json` в папке `backend/` и укажите путь в `.env`:

```bash
SERVICE_ACCOUNT_PATH=./service_account.json
```

## 3. Запуск сервера

```bash
dart run lib/main.dart
```

Сервер запустится на `http://localhost:8080`

## 4. Проверка работы

```bash
# Health check
curl http://localhost:8080/health

# Регистрация пользователя
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Aseke","surname":"Xasanov","studyGroup":"7d-9"}'
```

## 5. Использование в Flutter приложении

Обновите базовый URL в вашем Flutter приложении:

```dart
const String baseUrl = 'http://localhost:8080/api';
// или для продакшена:
// const String baseUrl = 'https://your-backend-domain.com/api';
```

## Структура API

- `POST /api/auth/register` - Регистрация
- `POST /api/auth/verify` - Верификация токена
- `POST /api/auth/admin/login` - Вход администратора
- `GET /api/goals/list` - Список целей
- `GET /api/donations/list` - Список пожертвований
- `POST /api/donations/create` - Создать пожертвование (требует токен)
- `GET /api/user/donations/count` - Количество пожертвований пользователя (требует токен)
- `POST /api/admin/goals/create` - Создать цель (требует admin токен)
- `PUT /api/admin/goals/update` - Обновить цель (требует admin токен)
- `DELETE /api/admin/goals/delete?goalName=...` - Удалить цель (требует admin токен)

Подробная документация в `README.md`.

