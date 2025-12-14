# Backend Deployment Guide

## ⚠️ ВАЖНО: Security First!

**НИКОГДА не храните credentials в клиентском коде!**

Это руководство покажет, как правильно настроить серверную часть для production deployment.

---

## 🏗️ Архитектура

```
Client (Flutter App)
    ↓ HTTPS
Cloud Functions (Firebase/GCP)
    ↓ Service Account
Google Sheets API
```

### Преимущества:
- ✅ Credentials в безопасности на сервере
- ✅ JWT токены с proper signing
- ✅ Rate limiting возможен
- ✅ Audit logs
- ✅ API versioning
- ✅ Ready for Play Market

---

## 📦 Option 1: Firebase Cloud Functions (Рекомендуется)

### Шаг 1: Установка Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Шаг 2: Инициализация проекта

```bash
cd backend
firebase init functions

# Select:
# - Use existing project or create new
# - JavaScript
# - ESLint: Yes
# - Install dependencies: Yes
```

### Шаг 3: Установка зависимостей

```bash
cd functions
npm install
```

Зависимости (уже в package.json):
- `firebase-admin` - Firebase SDK
- `firebase-functions` - Cloud Functions
- `googleapis` - Google Sheets API
- `jsonwebtoken` - JWT signing

### Шаг 4: Настройка Environment Variables

#### Via Firebase Console:
1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите ваш проект
3. Functions → Configuration
4. Add variable

#### Via CLI:

```bash
# Set spreadsheet ID
firebase functions:config:set sheets.spreadsheet_id="YOUR_SPREADSHEET_ID"

# Set app secret (for JWT signing)
firebase functions:config:set app.secret="YOUR_RANDOM_SECRET_KEY_256_BIT"

# Set service account (JSON as string)
firebase functions:config:set sheets.service_account='{"type":"service_account",...}'
```

#### Generate secure secret:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Шаг 5: Deploy Functions

```bash
firebase deploy --only functions
```

Output example:
```
✔  functions[registerUser]: Successful create operation.
✔  functions[createDonation]: Successful create operation.
...

Function URL (registerUser): https://us-central1-YOUR_PROJECT.cloudfunctions.net/registerUser
```

### Шаг 6: Тестирование

```bash
# Test registerUser
curl -X POST https://YOUR_PROJECT.cloudfunctions.net/registerUser \
  -H "Content-Type: application/json" \
  -d '{"data":{"fullName":"Test User","studyGroup":"TEST-01"}}'

# Should return:
# {"result":{"success":true,"token":"eyJ...","user":{...}}}
```

---

## 📦 Option 2: Google Cloud Functions (Альтернатива)

### Deploy to GCP:

```bash
# Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Deploy function
gcloud functions deploy registerUser \
  --runtime nodejs18 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point registerUser \
  --source functions/
```

---

## 🔐 Security Best Practices

### 1. Protect API Keys

**❌ НЕ ДЕЛАЙТЕ ТАК:**
```dart
// lib/main.dart
const credentials = {
  "private_key": "-----BEGIN PRIVATE KEY-----\n...", // ❌ EXPOSED!
};
```

**✅ ПРАВИЛЬНО:**
```dart
// Credentials хранятся ТОЛЬКО на сервере (Cloud Functions)
// Клиент использует только HTTPS endpoints
```

### 2. JWT Secret Management

```bash
# Generate strong secret (256-bit)
openssl rand -hex 32

# Store in Firebase config (NOT in code!)
firebase functions:config:set app.secret="YOUR_SECRET_HERE"
```

### 3. Service Account Permissions

В Google Cloud Console → IAM:
- Service Account должен иметь ТОЛЬКО "Sheets Editor" role
- НЕ давайте "Owner" или другие широкие права

### 4. CORS Configuration

Для web deployment добавьте CORS:

```javascript
// functions/index.js
const cors = require('cors')({ origin: true });

exports.registerUser = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    // Your function logic
  });
});
```

### 5. Rate Limiting

Добавьте rate limiting для защиты от abuse:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});

app.use(limiter);
```

---

## 📱 Flutter Client Integration

### Добавьте зависимости:

```yaml
dependencies:
  cloud_functions: ^4.5.0  # For Firebase
  http: ^1.1.0             # For REST calls
```

### Создайте API service:

```dart
// lib/core/services/api_service.dart
import 'package:cloud_functions/cloud_functions.dart';

class ApiService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // For non-Firebase deployment, use HTTPS endpoints:
  // final String baseUrl = 'https://YOUR_CLOUD_FUNCTION_URL';

  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String studyGroup,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('registerUser')
          .call({
        'fullName': fullName,
        'studyGroup': studyGroup,
      });

      return result.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> createDonation({
    required double amount,
    required String message,
  }) async {
    final result = await _functions
        .httpsCallable('createDonation')
        .call({
      'amount': amount,
      'message': message,
    });

    return result.data;
  }

  // ... other methods
}
```

---

## 🧪 Testing

### Local Emulator:

```bash
cd functions
npm install
firebase emulators:start --only functions

# Functions will run at:
# http://localhost:5001/YOUR_PROJECT/us-central1/registerUser
```

### Unit Tests:

```javascript
// functions/test/index.test.js
const test = require('firebase-functions-test')();
const myFunctions = require('../index');

describe('registerUser', () => {
  it('should register user successfully', async () => {
    const data = {
      fullName: 'Test User',
      studyGroup: 'TEST-01',
    };

    const result = await myFunctions.registerUser(data);
    expect(result.success).toBe(true);
    expect(result.token).toBeDefined();
  });
});
```

---

## 📊 Monitoring & Logs

### View Logs:

```bash
# Firebase
firebase functions:log

# GCP
gcloud functions logs read registerUser --limit 50
```

### Firebase Console:
- Functions → Dashboard
- See invocations, errors, execution time
- Set up alerts for errors

---

## 💰 Pricing

### Firebase (Free tier):
- 2M invocations/month
- 400,000 GB-seconds compute time
- 200,000 CPU-seconds compute time
- 5GB outbound networking

### Достаточно для:
- ~50-100 пользователей
- ~1000 донатов/месяц

### Paid tier (Blaze):
- $0.40 per million invocations
- Pay only for what you use

---

## 🚀 Production Checklist

### Before Deploy:

- [ ] Environment variables set (Spreadsheet ID, Secret, Service Account)
- [ ] Service Account has correct permissions
- [ ] JWT secret is strong (256-bit random)
- [ ] CORS configured (if needed)
- [ ] Rate limiting enabled
- [ ] Error handling tested
- [ ] Logs monitoring set up
- [ ] Costs estimated

### After Deploy:

- [ ] Test all endpoints from client
- [ ] Monitor first 24 hours for errors
- [ ] Set up alerts for failures
- [ ] Document API endpoints for team
- [ ] Update client app with production URLs

---

## 🆘 Troubleshooting

### Error: "Permission denied"
- Check Service Account permissions in Google Cloud Console
- Ensure Sheets API is enabled

### Error: "Invalid token"
- Verify APP_SECRET matches between signing and verification
- Check token expiration

### Error: "Spreadsheet not found"
- Verify SPREADSHEET_ID in config
- Check Service Account has access to Sheet

### Error: "Rate limit exceeded"
- Increase limits or upgrade plan
- Implement caching in client

---

## 📚 Resources

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [Google Sheets API](https://developers.google.com/sheets/api)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [Cloud Functions Security](https://firebase.google.com/docs/functions/security)

---

## ⏭️ Next Steps

1. Deploy Cloud Functions
2. Update Flutter app to use API endpoints
3. Remove credentials from client code
4. Test production flow
5. Ready for Play Market! 🎉

