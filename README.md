# Repository Quality Analyzer
[![CI](https://github.com/Egor1007-del/rails-developer-project-66/actions/workflows/ci.yml/badge.svg)](https://github.com/Egor1007-del/rails-developer-project-66/actions/workflows/ci.yml)
## Hexlet tests and linter status:
[![Actions Status](https://github.com/Egor1007-del/rails-developer-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Egor1007-del/rails-developer-project-66/actions)

## Демо
Приложение доступно по ссылке: 
[открыть приложение](https://rails-developer-project-66-1.onrender.com/)

## Требования

- Ruby 4.0.6
- Rails 8.1
- Node.js
- Yarn
- SQLite 3
- GNU Make

## Установка

Клонируйте репозиторий и перейдите в каталог проекта:

```bash
git clone https://github.com/Egor1007-del/rails-developer-project-66.git
cd rails-developer-project-66
```
## Установите зависимости, соберите ассеты и подготовьте базу данных:

```bash
make setup
```
Команда также создаст локальный файл .env из шаблона .env.example, если .env ещё не существует.

## Запуск

Запустите приложение:

```bash
make start
```

После запуска оно будет доступно по адресу:

http://localhost:3000