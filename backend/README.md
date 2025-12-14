# Donation App Backend

Backend server для Donation App с JWT аутентификацией и интеграцией Google Sheets.

## Технологии

- **Dart** - основной язык
- **Shelf** - веб-фреймворк
- **JWT** - токены для аутентификации
- **Google Sheets API** - хранение данных

## Структура

```
backend/
├── lib/
│   ├── main.dart                    # Точка входа сервера
│   ├── config/
│   │   └── config.dart              # Конфигурация (env variables)
│   ├── services/
│   │   ├── jwt_service.dart         # JWT генерация и валидация
│   │   └── google_sheets_service.dart # Google Sheets API
│   ├── middleware/
│   │   ├── auth_middleware.dart     # JWT аутентификация
│   │   └── error_middleware.dart    # Обработка ошибок
│   └── routes/
│       ├── auth_routes.dart         # Регистрация, логин, верификация
│       ├── user_routes.dart         # Пользовательские эндпоинты
│       ├── donation_routes.dart     # Пожертвования
│       ├── goals_routes.dart        # Цели сбора
│       └── admin_routes.dart        # Админ панель (CRUD)
├── .env.example                     # Пример конфигурации
└── pubspec.yaml                     # Зависимости
```

## Установка

1. Установите Dart SDK: https://dart.dev/get-dart

2. Установите зависимости:
```bash
cd backend
dart pub get
```

3. Создайте файл `.env` на основе `.env.example`:
```bash
cp .env.example .env
```

4. Заполните `.env` файл:
   - `JWT_SECRET` - секретный ключ для JWT (измените в продакшене!)
   - `SPREADSHEET_ID` - ID вашей Google таблицы
   - `ADMIN_PASSWORD` - пароль администратора
   - `SERVICE_ACCOUNT_JSON` - JSON ключ service account (или используйте `SERVICE_ACCOUNT_PATH`)

## Запуск

### Development
```bash
dart run lib/main.dart
```

### Production
```bash
dart compile exe lib/main.dart -o donation_backend
./donation_backend
```

Сервер запустится на порту 8080 (или из переменной окружения `PORT`).

## API Endpoints

### Public Endpoints

#### `POST /api/auth/register`
Регистрация нового пользователя.

**Request:**
```json
{
  "fullName": "Aseke",
  "surname": "Xasanov",
  "studyGroup": "7d-9"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "userId": "1234567890_abc123",
    "userName": "Aseke",
    "surname": "Xasanov",
    "userGroup": "7d-9",
    "registeredAt": "2024-01-15T10:30:00Z"
  }
}
```

#### `POST /api/auth/verify`
Верификация JWT токена.

**Request:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "valid": true,
  "user": {
    "userId": "1234567890_abc123",
    "userName": "Aseke",
    "surname": "Xasanov",
    "userGroup": "7d-9"
  }
}
```

#### `POST /api/auth/admin/login`
Вход администратора.

**Request:**
```json
{
  "password": "admin2024"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "isAdmin": true
}
```

#### `GET /api/goals/list`
Получить все цели сбора.

**Response:**
```json
{
  "goals": [
    {
      "name": "Новые компьютеры",
      "targetAmount": 500000,
      "currentAmount": 125000,
      "deadline": "2024-12-31",
      "description": "Покупка 10 новых ПК"
    }
  ]
}
```

#### `GET /api/goals/total`
Получить общую сумму собранных пожертвований.

**Response:**
```json
{
  "total": 125000.0
}
```

#### `GET /api/donations/list`
Получить все пожертвования.

**Response:**
```json
{
  "donations": [
    {
      "fullName": "Aseke Xasanov",
      "studyGroup": "7d-9",
      "amount": 5000,
      "date": "2024-01-20T14:00:00Z",
      "message": "На новое оборудование"
    }
  ]
}
```

### Protected Endpoints (требуют JWT токен)

**Header:** `Authorization: Bearer <token>`

#### `POST /api/donations/create`
Создать пожертвование.

**Request:**
```json
{
  "amount": 5000,
  "message": "На новое оборудование"
}
```

**Response:**
```json
{
  "success": true,
  "donation": {
    "fullName": "Aseke Xasanov",
    "studyGroup": "7d-9",
    "amount": 5000,
    "date": "2024-01-20T14:00:00Z",
    "message": "На новое оборудование"
  }
}
```

#### `GET /api/user/donations/count`
Получить количество пожертвований текущего пользователя.

**Response:**
```json
{
  "count": 5
}
```

### Admin Endpoints (требуют admin JWT токен)

#### `POST /api/admin/goals/create`
Создать новую цель.

**Request:**
```json
{
  "name": "Новые компьютеры",
  "targetAmount": 500000,
  "deadline": "2024-12-31",
  "description": "Покупка 10 новых ПК"
}
```

#### `PUT /api/admin/goals/update`
Обновить цель.

**Request:**
```json
{
  "originalName": "Новые компьютеры",
  "name": "Новые компьютеры",
  "targetAmount": 500000,
  "currentAmount": 125000,
  "deadline": "2024-12-31",
  "description": "Покупка 10 новых ПК"
}
```

#### `DELETE /api/admin/goals/delete?goalName=Новые компьютеры`
Удалить цель.

#### `DELETE /api/admin/donations/delete`
Удалить пожертвование.

**Request:**
```json
{
  "fullName": "Aseke Xasanov",
  "date": "2024-01-20T14:00:00Z"
}
```

#### `DELETE /api/admin/users/delete?fullName=Aseke Xasanov`
Удалить пользователя.

## JWT Token Structure

### User Token
```json
{
  "userId": "1234567890_abc123",
  "userName": "Aseke",
  "surname": "Xasanov",
  "userGroup": "7d-9",
  "iat": 1705315800,
  "exp": 1707907800
}
```

### Admin Token
```json
{
  "adminId": "admin_1234567890",
  "isAdmin": true,
  "iat": 1705315800,
  "exp": 1705920600
}
```

## Безопасность

⚠️ **ВАЖНО для продакшена:**

1. **Измените JWT_SECRET** - используйте сильный случайный ключ
2. **Используйте HTTPS** - настройте SSL/TLS сертификат
3. **Ограничьте CORS** - настройте `shelf_cors_headers` для вашего домена
4. **Храните секреты безопасно** - используйте переменные окружения или секреты менеджеры
5. **Логируйте запросы** - для мониторинга и отладки

## Развертывание

### Docker (рекомендуется)

Создайте `Dockerfile`:
```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe lib/main.dart -o /app/donation_backend

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/donation_backend /app/donation_backend
WORKDIR /app
EXPOSE 8080
CMD ["/app/donation_backend"]
```

### Systemd Service

Создайте `/etc/systemd/system/donation-backend.service`:
```ini
[Unit]
Description=Donation App Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/donation-backend
ExecStart=/opt/donation-backend/donation_backend
Restart=always
Environment="PORT=8080"
EnvironmentFile=/opt/donation-backend/.env

[Install]
WantedBy=multi-user.target
```

## Тестирование

```bash
# Health check
curl http://localhost:8080/health

# Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Aseke","surname":"Xasanov","studyGroup":"7d-9"}'

# Verify token
curl -X POST http://localhost:8080/api/auth/verify \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN_HERE"}'
```

## Логирование

Сервер логирует все запросы и ошибки. Уровень логирования настраивается в `main.dart`.

## Поддержка

Для вопросов и проблем создайте issue в репозитории проекта.

