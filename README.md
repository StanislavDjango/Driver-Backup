# DriverVault

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

Useful project pages:

- [Contributing guide](CONTRIBUTING.md)
- [Security notes](SECURITY.md)
- [Changelog](CHANGELOG.md)
- [MIT License](LICENSE)

## What It Does

- Backs up third-party Windows driver packages from the local driver store.
- Restores saved `.inf` driver packages with built-in Windows tools.
- Checks backup integrity with SHA256 checksums before restore.
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
8. Run `RESTORE_DRIVERS.cmd` from the backup folder as Administrator, or open DriverVault and click **Restore**.
9. Reboot Windows after restore.

### Русский

1. Скачайте или клонируйте этот репозиторий.
2. Нажмите правой кнопкой по `DriverVault.cmd` и выберите **Запуск от имени администратора**.
3. Выберите папку резервной копии.
4. Оставьте режим **Рекомендуемый** для обычной копии или выберите **Полная копия**, чтобы скопировать весь DriverStore.
5. Нажмите **Сохранить**.
6. Перед переустановкой Windows перенесите созданную папку на флешку или другой надежный диск.
7. После переустановки Windows верните папку резервной копии на этот же компьютер.
8. Запустите `RESTORE_DRIVERS.cmd` из папки резервной копии от имени администратора или откройте DriverVault и нажмите **Восстановить**.
9. После восстановления перезагрузите Windows.

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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\DriverVault.ps1 -Mode Restore -BackupPath "D:\DriverVault_Backup"
```

## Build EXE

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-DriverVaultExe.ps1
```

The build script uses PS2EXE and creates `dist\DriverVault.exe`. Generated binaries are not required for development; the `.ps1` and `.cmd` files are enough to run the tool.

## License

DriverVault is released under the [MIT License](LICENSE).
