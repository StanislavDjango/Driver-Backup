# Contributing to DriverVault

Thank you for helping improve DriverVault. This project is intentionally small, portable and easy to audit. Please keep changes focused and practical.

## English

### Development Setup

1. Use Windows 10 or Windows 11.
2. Use Windows PowerShell 5.1.
3. Clone the repository.
4. Run the GUI:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Gui -Language en
```

5. Build the EXE wrapper when needed:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-DriverVaultExe.ps1
```

### Code Style

- Prefer built-in Windows tools and PowerShell APIs.
- Keep the application portable: no installer and no required external service.
- Keep UI text localized in both Russian and English.
- Avoid unrelated formatting churn.
- Do not add driver download logic or automatic online driver installation.
- Treat backup folders as private user data.

### Test Checklist

Before opening a pull request, test what your change touches:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Inspect -BackupPath . -Language en -NoPause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Inspect -BackupPath . -Language ru -NoPause
```

For backup-related changes, create a real test backup on a non-critical machine and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Validate -BackupPath "D:\DriverVault_Test" -Language en -NoPause
```

Do not run restore tests on a production machine unless you understand the risk.

### Pull Request Checklist

- Explain the problem and the solution.
- Mention tested Windows version.
- Mention whether Administrator rights were used.
- Update English and Russian documentation when behavior changes.
- Do not commit personal backup folders, logs with private hardware data, ZIP archives or generated `dist` builds.

## Русский

Спасибо за помощь в развитии DriverVault. Проект специально остается небольшим, портативным и понятным для проверки. Пожалуйста, делайте изменения точечно и по делу.

### Подготовка окружения

1. Используйте Windows 10 или Windows 11.
2. Используйте Windows PowerShell 5.1.
3. Клонируйте репозиторий.
4. Запустите интерфейс:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Gui -Language ru
```

5. При необходимости соберите EXE-лаунчер:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-DriverVaultExe.ps1
```

### Стиль кода

- Предпочитайте штатные инструменты Windows и PowerShell API.
- Сохраняйте портативность: без установщика и обязательных внешних сервисов.
- Добавляйте текст интерфейса сразу на русском и английском.
- Не делайте лишних форматирований в несвязанных местах.
- Не добавляйте скачивание драйверов или автоматическую установку драйверов из интернета.
- Считайте папки резервных копий личными данными пользователя.

### Что проверить

Перед pull request проверьте то, что меняли:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Inspect -BackupPath . -Language en -NoPause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Inspect -BackupPath . -Language ru -NoPause
```

Для изменений, связанных с сохранением, создайте реальную тестовую копию на неважной машине и выполните:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Validate -BackupPath "D:\DriverVault_Test" -Language ru -NoPause
```

Не запускайте восстановление на рабочей машине, если не понимаете риск.

### Перед отправкой pull request

- Опишите проблему и решение.
- Укажите протестированную версию Windows.
- Укажите, использовались ли права администратора.
- Обновите русскую и английскую документацию, если поведение изменилось.
- Не коммитьте личные резервные копии, журналы с приватными данными железа, ZIP-архивы и сгенерированные сборки из `dist`.
