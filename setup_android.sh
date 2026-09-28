#!/bin/sh
set -e
flutter pub get
flutter create . --platforms=android --org ru.kibi --project-name kibi
flutter pub get
echo "Готово. Запуск: flutter run"
