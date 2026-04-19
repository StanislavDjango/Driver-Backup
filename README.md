# DriverVault

<p align="center">
  <img src="assets/DriverVault.png" alt="DriverVault icon" width="96">
</p>

<p align="center">
  <a href="https://github.com/StanislavDjango/Driver-Backup/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/StanislavDjango/Driver-Backup?label=latest"></a>
  <img alt="Windows" src="https://img.shields.io/badge/platform-Windows-2478d4">
  <img alt="PowerShell" src="https://img.shields.io/badge/PowerShell-5.1-5391FE">
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-green"></a>
</p>

DriverVault is a portable Windows utility for backing up the drivers already installed on a PC and restoring them after Windows is reinstalled.

DriverVault - портативная утилита для Windows, которая сохраняет уже установленные драйверы этого компьютера и помогает восстановить их после переустановки Windows.

## Documentation

| Language | Guide |
| --- | --- |
| English | [Full English documentation](docs/en/README.md) |
| Русский | [Полная документация на русском](docs/ru/README.md) |

## Download Ready-To-Run EXE

For most users, the easiest option is to download the ready-to-run Windows EXE:

[Download DriverVault.exe](https://github.com/StanislavDjango/Driver-Backup/releases/latest/download/DriverVault.exe)

Для большинства пользователей самый простой вариант - скачать готовый EXE-файл:

[Скачать DriverVault.exe](https://github.com/StanislavDjango/Driver-Backup/releases/latest/download/DriverVault.exe)

After download, right-click `DriverVault.exe` and choose **Run as administrator**.

После загрузки нажмите правой кнопкой по `DriverVault.exe` и выберите **Запуск от имени администратора**.

## Screenshots

### Русский интерфейс

![DriverVault Russian interface](docs/assets/screenshots/drivervault-ru.png)

### English Interface

![DriverVault English interface](docs/assets/screenshots/drivervault-en.png)

Useful project pages:

- [Contributing guide](CONTRIBUTING.md)
- [Security notes](SECURITY.md)
- [Changelog](CHANGELOG.md)
- [MIT License](LICENSE)

## What It Does

- Backs up third-party Windows driver packages from the local driver store.
- Restores saved `.inf` driver packages with built-in Windows tools.
- Checks backup integrity with SHA256 checksums before restore.
- Runs a dry-run restore check that lists which INF packages would be sent to Windows without installing anything.
- Shows clear recovery errors such as missing Administrator rights, damaged backup folders, missing INF files and wrong-PC backups.
- Uses a custom shield, archive and chip icon for the app window and EXE.
- Shows a dedicated backup details window with creation date, PC model, Windows version, mode, INF count, SHA256 status and current-PC match.
- Checks available disk space before backup and before ZIP creation.
- Keeps a manifest with machine information, driver counts, backup mode and timestamps.
- Supports Russian and English user interface text.
- Provides a compact GUI with progress, cancellation, final status and detailed log files.

## Quick Start

### English

1. Download or clone this repository.
2. Right-click `DriverVault.cmd` and choose **Run as administrator**.
3. Choose a backup folder.
4. Keep **Recommended** mode for a normal backup, or choose **Full** to copy the whole DriverStore.
5. Click **Backup**.
6. Copy the created backup folder to a USB drive or another safe disk before reinstalling Windows.
7. After reinstalling Windows, copy the backup folder back to the same PC.
8. Click **Dry run** to see which driver packages would be sent to Windows without installing them.
9. Run `RESTORE_DRIVERS.cmd` from the backup folder as Administrator, or open DriverVault and click **Restore**.
10. Reboot Windows after restore.

### Русский

1. Скачайте или клонируйте этот репозиторий.
2. Нажмите правой кнопкой по `DriverVault.cmd` и выберите **Запуск от имени администратора**.
3. Выберите папку резервной копии.
4. Оставьте режим **Рекомендуемый** для обычной копии или выберите **Полная копия**, чтобы скопировать весь DriverStore.
5. Нажмите **Сохранить**.
6. Перед переустановкой Windows перенесите созданную папку на флешку или другой надежный диск.
7. После переустановки Windows верните папку резервной копии на этот же компьютер.
8. Нажмите **Пробное**, чтобы увидеть, какие пакеты драйверов будут отправлены Windows без установки.
9. Запустите `RESTORE_DRIVERS.cmd` из папки резервной копии от имени администратора или откройте DriverVault и нажмите **Восстановить**.
10. После восстановления перезагрузите Windows.

## Safety First

DriverVault does not download drivers from the internet and does not install random driver-pack bundles. It restores only driver packages that were already present in the Windows driver store on this machine.

DriverVault не скачивает драйверы из интернета и не устанавливает случайные driver-pack сборки. Он восстанавливает только те пакеты драйверов, которые уже были в хранилище драйверов Windows на этой машине.

## Project Files

| File | Purpose |
| --- | --- |
| `DriverVault.ps1` | Main PowerShell application. |
| `DriverVault.cmd` | Easy launcher for the GUI. |
| `Build-DriverVaultExe.ps1` | Builds a Windows EXE with PS2EXE. |
| `Build-DriverVaultExe.cmd` | Easy launcher for the build script. |
| `docs/en/README.md` | Full English guide. |
| `docs/ru/README.md` | Full Russian guide. |
| `CONTRIBUTING.md` | Development and contribution guide. |

## Command Line

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Gui
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Backup -BackupPath "D:\DriverVault_Backup" -BackupScope Recommended
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Validate -BackupPath "D:\DriverVault_Backup"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode DryRun -BackupPath "D:\DriverVault_Backup"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Restore -BackupPath "D:\DriverVault_Backup"
```

## Build EXE

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-DriverVaultExe.ps1
```

The build script uses PS2EXE and creates `dist\DriverVault.exe`. Generated binaries are not required for development; the `.ps1` and `.cmd` files are enough to run the tool.

GitHub Actions also builds release binaries automatically whenever a version tag like `v0.4.0` is pushed.

## Run Tests

DriverVault uses Pester tests for the core backup validation, inspect, dry-run, checksum and guard logic:

```powershell
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck -MinimumVersion 5.5.0
Invoke-Pester -Path .\tests -CI
```

GitHub Actions runs the parser check and Pester tests before building the EXE.

## License

DriverVault is released under the [MIT License](LICENSE).
