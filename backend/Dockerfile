# Dockerfile для Dart backend сервера
FROM dart:stable AS build

WORKDIR /app

# Копируем pubspec файлы
COPY pubspec.* ./
RUN dart pub get

# Копируем весь код
COPY . .

# Компилируем в исполняемый файл
RUN dart compile exe lib/main.dart -o server

# Финальный образ
FROM debian:bookworm-slim

WORKDIR /app

# Копируем скомпилированный файл
COPY --from=build /app/server /app/server

# Устанавливаем необходимые библиотеки
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Открываем порт (Railway автоматически устанавливает PORT)
EXPOSE 8080

# Запускаем сервер
CMD ["./server"]

