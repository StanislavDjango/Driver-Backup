# Changelog

All notable changes to DriverVault will be documented in this file.

## Unreleased

- Added full English and Russian documentation for GitHub.
- Added contribution and security guidance.
- Documented command-line usage, backup modes, validation and restore workflow.

## 0.4.0

- Added a dedicated GUI backup details window for the **Details** action.
- Details now show creation date, PC model, Windows version, backup mode, INF count, file count, size, SHA256 status and current-PC match.
- Details now save an `inspect_report_*.txt` report in the backup `Logs/` folder.
- Added free-space checks before backup and before ZIP archive creation.

## 0.3.2

- Redesigned the DriverVault icon around a shield, archive box and driver chip.
- Regenerated `assets/DriverVault.png` and `assets/DriverVault.ico` from the reproducible icon script.
- The PowerShell GUI now uses the DriverVault icon when the `assets` folder is present.

## 0.3.1

- Added clearer user-facing recovery errors for Administrator rights, busy files, damaged backups, missing INF files and wrong-PC backups.
- Kept technical error details in log files while showing short actionable messages in the GUI and CLI.
- Restore now stops when the backup manifest clearly belongs to a different PC.
- DryRun and Restore now validate the selected backup path before creating log folders.

## 0.3.0

- Added DryRun restore mode for checking backups without installing drivers.
- Added GUI **Dry run** / **Пробное** action.
- DryRun checks INF files, file readability, machine identity and driver candidates.
- DryRun writes a detailed report to the backup `Logs/` folder.

## 0.2.0

- Added a custom DriverVault icon and connected it to EXE builds.
- Added Russian and English screenshots to the GitHub documentation.
- Added GitHub Actions workflow for automatic EXE builds and release publishing.
- Added reproducible helper scripts for icon and screenshot generation.

## 0.1.1

- Fixed responsive GUI layout for wide windows.
- Aligned action buttons into one compact row.
- Kept the Cancel button pinned to the top-right of the action area.
- Prevented long status and option text from overflowing outside its controls.

## 0.1.0

- Added Windows driver backup and restore GUI.
- Added Russian and English UI language support.
- Added Recommended and Full backup modes.
- Added SHA256 validation for backup integrity.
- Added backup manifest and driver inventory files.
- Added restore pre-check before driver installation.
- Added cancel button, progress status, final summaries and quiet error handling.
- Added PS2EXE build script.
- Published ready-to-run `DriverVault.exe` through GitHub Releases.

---

# Журнал изменений

Здесь фиксируются заметные изменения DriverVault.

## Следующая версия

- Добавлена подробная документация для GitHub на английском и русском языках.
- Добавлены правила участия в разработке и заметки по безопасности.
- Описаны командная строка, режимы сохранения, проверка и восстановление.

## 0.4.0

- Добавлено отдельное окно сведений о копии для кнопки **Сведения**.
- В сведениях теперь видны дата создания, модель ПК, Windows, режим копии, INF, количество файлов, размер, SHA256 и совпадение с текущим ПК.
- Сведения сохраняют отчёт `inspect_report_*.txt` в папку `Logs/` резервной копии.
- Добавлена проверка свободного места перед сохранением и перед созданием ZIP-архива.

## 0.3.2

- Переработана иконка DriverVault: щит, архивная коробка и чип драйвера.
- `assets/DriverVault.png` и `assets/DriverVault.ico` заново генерируются воспроизводимым скриптом.
- PowerShell GUI теперь использует иконку DriverVault, если рядом есть папка `assets`.

## 0.3.1

- Добавлены понятные ошибки для прав администратора, занятых файлов, повреждённых копий, отсутствующих INF-файлов и копий от другого ПК.
- Технические подробности остаются в журнале, а в GUI и CLI показывается короткое действие для пользователя.
- Восстановление теперь останавливается, если manifest явно показывает другой ПК.
- DryRun и Restore сначала проверяют выбранную папку копии и не создают пустые папки при ошибочном пути.

## 0.3.0

- Добавлен режим пробного восстановления без установки драйверов.
- Добавлена кнопка **Пробное** в графический интерфейс.
- Пробный режим проверяет INF-файлы, чтение файлов, совпадение компьютера и кандидаты драйверов.
- Пробный режим сохраняет подробный отчёт в папку `Logs/` резервной копии.

## 0.2.0

- Добавлена собственная иконка DriverVault и подключена к сборке EXE.
- Добавлены русские и английские скриншоты в документацию GitHub.
- Добавлен GitHub Actions workflow для автоматической сборки EXE и публикации релизов.
- Добавлены воспроизводимые вспомогательные скрипты для генерации иконки и скриншотов.

## 0.1.1

- Исправлена адаптивная раскладка интерфейса для широких окон.
- Кнопки действий выровнены в одну компактную строку.
- Кнопка **Отмена** закреплена справа сверху в блоке действий.
- Длинные статусы и подписи больше не вылезают за границы элементов.

## 0.1.0

- Добавлен графический интерфейс для сохранения и восстановления драйверов Windows.
- Добавлена поддержка русского и английского языка интерфейса.
- Добавлены режимы **Рекомендуемый** и **Полная копия**.
- Добавлена проверка целостности резервной копии через SHA256.
- Добавлены manifest-файл и список установленных драйверов.
- Добавлена предварительная проверка перед восстановлением.
- Добавлены кнопка отмены, прогресс, итоговые статусы и тихая обработка ошибок.
- Добавлен скрипт сборки через PS2EXE.
- Готовый `DriverVault.exe` опубликован через GitHub Releases.
