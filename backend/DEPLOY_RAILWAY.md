# Деплой на Railway.app (БЕСПЛАТНО, без Blaze плана!)

## 🚀 Быстрый деплой за 5 минут

### Шаг 1: Создайте аккаунт на Railway
1. Откройте https://railway.app
2. Войдите через GitHub
3. Нажмите "New Project"

### Шаг 2: Подключите репозиторий
1. Выберите "Deploy from GitHub repo"
2. Выберите ваш репозиторий
3. Выберите папку `backend`

### Шаг 3: Настройте переменные окружения
В Railway Dashboard → Variables добавьте:

```
JWT_SECRET=ваш-секретный-ключ-256-бит
SPREADSHEET_ID=1qMwgXatKVAywkdGbTQYpKV6jNzXQhbjwrduajKXlA-o
ADMIN_PASSWORD=admin2024
SERVICE_ACCOUNT_JSON={"type":"service_account",...}
PORT=8080
```

**Или** используйте файл:
```
SERVICE_ACCOUNT_PATH=/app/service_account.json
```

### Шаг 4: Деплой
Railway автоматически:
- Соберет Docker образ
- Задеплоит сервер
- Даст вам URL (например: `https://your-app.railway.app`)

### Шаг 5: Обновите Flutter приложение
В `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'https://your-app.railway.app/api';
```

## ✅ Готово!

**Преимущества Railway:**
- ✅ Бесплатный тариф: $5 кредитов/месяц
- ✅ Автоматический деплой из GitHub
- ✅ HTTPS из коробки
- ✅ Не нужен Blaze план
- ✅ Простая настройка

---

## Альтернатива: Render.com

### Шаг 1: Создайте аккаунт
https://render.com

### Шаг 2: New → Web Service
- Connect GitHub repo
- Root Directory: `backend`
- Build Command: `dart pub get && dart compile exe lib/main.dart -o server`
- Start Command: `./server`

### Шаг 3: Environment Variables
Добавьте те же переменные, что и для Railway

**Бесплатный тариф:** 750 часов/месяц

---

## Альтернатива: Google Cloud Run (тоже бесплатно!)

### Шаг 1: Установите gcloud CLI
```bash
# macOS
brew install google-cloud-sdk
gcloud init
```

### Шаг 2: Соберите и задеплойте
```bash
cd backend

# Соберите Docker образ
docker build -t gcr.io/state-projects/donation-backend .

# Задеплойте
gcloud run deploy donation-backend \
  --image gcr.io/state-projects/donation-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars JWT_SECRET=...,SPREADSHEET_ID=...
```

**Бесплатный лимит:** 2M запросов/месяц

---

## Какой вариант выбрать?

1. **Railway** - самый простой, рекомендую для начала
2. **Render** - хорошая альтернатива
3. **Cloud Run** - если уже используете Google Cloud

**Все варианты БЕСПЛАТНЫ и НЕ требуют Blaze план!**

