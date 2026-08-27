# Repository Quality Analyzer

[![CI](https://github.com/Egor1007-del/rails-developer-project-66/actions/workflows/ci.yml/badge.svg)](https://github.com/Egor1007-del/rails-developer-project-66/actions/workflows/ci.yml)

[![Hexlet tests and linter status](https://github.com/Egor1007-del/rails-developer-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Egor1007-del/rails-developer-project-66/actions)

Веб-приложение для автоматического анализа качества GitHub-репозиториев.

Пользователь может подключить свой GitHub-репозиторий, после чего приложение отслеживает изменения через webhook и запускает проверку кода с помощью соответствующего линтера.

Результаты проверки сохраняются в базе данных и доступны пользователю в виде отчёта.

## Демо

Приложение доступно по адресу:

[Открыть приложение](https://rails-developer-project-66-1.onrender.com/)

## Возможности

- Авторизация пользователей через GitHub.
- Подключение GitHub-репозиториев.
- Фильтрация репозиториев по поддерживаемому языку.
- Автоматическая установка GitHub webhook.
- Запуск проверки репозитория вручную.
- Автоматический запуск проверки после `push` в GitHub.
- Проверка Ruby-кода с помощью RuboCop.
- Проверка JavaScript-кода с помощью ESLint.
- Просмотр результатов проверки.
- Отображение найденных нарушений и их местоположения в исходном коде.
- Подсчёт количества нарушений.
- Отправка email-уведомления при неуспешной проверке.
- Выполнение длительных проверок в фоновых задачах.
- Кэширование данных, получаемых из GitHub API.

## Как это работает

### Ручная проверка

Пользователь открывает подключённый репозиторий и запускает проверку.

```text
Пользователь
    ↓
ChecksController
    ↓
RepositoryCheckJob
    ↓
RepositoryChecker
    ↓
RepositoryLoader
    ↓
RuboCop / ESLint
    ↓
Repository::Check
```

Результат проверки сохраняется в базе данных.

### Автоматическая проверка через GitHub webhook

После установки webhook GitHub отправляет запрос приложению при `push`:

```text
GitHub
   ↓
POST /api/checks
   ↓
проверка подписи webhook
   ↓
создание Repository::Check
   ↓
RepositoryCheckJob
   ↓
RepositoryChecker
   ↓
RuboCop / ESLint
```

Сама проверка выполняется в фоновой задаче, поэтому GitHub не должен ждать завершения анализа кода.

## Требования

- Ruby 4.0.6
- Rails 8.1
- Node.js
- Yarn
- SQLite 3
- GNU Make

## Установка

Клонируйте репозиторий:

```bash
git clone https://github.com/Egor1007-del/rails-developer-project-66.git
cd rails-developer-project-66
```

Установите зависимости и подготовьте приложение:

```bash
make setup
```

Команда:

- создаёт `.env` из `.env.example`, если файл ещё не существует;
- устанавливает Ruby-зависимости;
- подготавливает assets;
- создаёт и мигрирует базу данных.

## Переменные окружения

Перед запуском приложения необходимо настроить переменные окружения в `.env`.

Пример находится в файле:

```text
.env.example
```

В зависимости от конфигурации приложения могут потребоваться:

```text
GITHUB_CLIENT_ID
GITHUB_CLIENT_SECRET
GITHUB_WEBHOOK_SECRET
```

## Запуск

Запустите Rails-сервер:

```bash
make start
```

После запуска приложение будет доступно по адресу:

```text
http://localhost:3000
```

Можно указать другой порт:

```bash
make start PORT=4000
```

## Проверка кода

Для запуска RuboCop:

```bash
make lint
```

Команда выполняет:

```bash
bundle exec rubocop
```

## Тесты

Для запуска всех тестов:

```bash
bin/rails test
```

Для запуска отдельного теста:

```bash
bin/rails test test/services/repository_checker_test.rb
```

## Структура приложения

Основная логика приложения разделена между контроллерами, сервисами и фоновыми задачами.

### Controllers

Web-контроллеры отвечают за HTTP-запросы пользовательского интерфейса.

API-контроллер принимает GitHub webhook и передаёт проверку в фоновую задачу.

### Services

Сервисы содержат основную бизнес-логику:

- получение репозиториев из GitHub;
- создание репозитория;
- установку webhook;
- загрузку репозитория;
- запуск соответствующего линтера;
- обработку результата проверки.

### Background Jobs

Длительные операции выполняются через Active Job:

```ruby
RepositoryCheckJob
```

Задача запускает:

```ruby
RepositoryChecker
```

в фоновом режиме.

### Linters

Приложение поддерживает:

- RuboCop для Ruby;
- ESLint для JavaScript.

Результат работы линтера сохраняется в `Repository::Check`.

## Кэширование

Данные, получаемые из GitHub API, кэшируются для уменьшения количества внешних запросов.

Это позволяет не обращаться к GitHub повторно при каждом открытии формы добавления репозитория.

## Webhook

Для автоматического запуска проверок приложение использует GitHub webhook.

Каждый webhook проверяется с помощью `X-Hub-Signature-256`.

Неподписанные или некорректно подписанные запросы отклоняются.

## Локализация

Пользовательский интерфейс и сообщения об ошибках локализованы с помощью Rails I18n.

Основная локаль приложения:

```text
ru
```

Локализации находятся в:

```text
config/locales/
```

## Лицензия

Проект создан в рамках учебного проекта Hexlet.