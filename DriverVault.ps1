param(
    [ValidateSet("Gui", "Backup", "Restore", "Inspect", "Validate", "DryRun")]
    [string]$Mode = "Gui",

    [string]$BackupPath = "",

    [switch]$CreateZip,

    [ValidateSet("Auto", "ru", "en")]
    [string]$Language = "Auto",

    [ValidateSet("Recommended", "Full")]
    [string]$BackupScope = "Recommended",

    [switch]$NoPause
)

$ErrorActionPreference = "Stop"
$script:AppName = "DriverVault"
$script:LogFile = $null
$script:GuiLogBox = $null
$script:GuiMode = ($Mode -eq "Gui")
$script:GuiProgressBar = $null
$script:GuiStatusLabel = $null
$script:GuiSummaryLabel = $null
$script:GuiAdminValueLabel = $null
$script:GuiInfValueLabel = $null
$script:GuiLastValueLabel = $null
$script:CancelRequested = $false
$script:CurrentProcess = $null
$script:UiLanguage = if ($Language -eq "Auto") {
    if ([Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -eq "ru") { "ru" } else { "en" }
} else {
    $Language
}
$script:NativeOutputEncoding = [Text.Encoding]::Default
$script:Strings = @{
    en = @{
        AdminYes              = "Admin access: ready"
        AdminNo               = "Admin access needed"
        BackupButton          = "Backup"
        BackupCompleted       = "Backup completed."
        BackupFolder          = "Backup folder:"
        BackupLooksUsable     = "Backup looks usable."
        BackupModeLabel       = "Mode:"
        BackupModeRecommended = "Recommended"
        BackupModeFull        = "Full"
        BackupRequiresAdmin   = "No administrator rights. Restart DriverVault as Administrator before backup."
        BackupRoot            = "Backup root: {0}"
        BrowseButton          = "Browse"
        BrowseDescription     = "Choose an existing backup folder or a parent folder for a new backup."
        CollectInventory      = "Collecting machine identity and installed driver inventory."
        CommandFailed         = "{1} failed with exit code {0}. Check the log for technical details."
        Created               = "Created: {0}"
        CreatingZip           = "Creating ZIP archive: {0}"
        DriversFolderMissing  = "Backup folder looks damaged: Drivers folder is missing: {0}"
        DryRunButton          = "Dry run"
        DryRunCandidate       = "Would add: {0}"
        DryRunCompleted       = "Dry-run restore completed. No drivers were installed."
        DryRunFileReadableOk  = "File readability check passed: {0} files."
        DryRunFileUnreadable  = "Unreadable file: {0}"
        DryRunMachineMismatch = "possible different PC"
        DryRunMachineSame     = "same PC"
        DryRunMachineUnknown  = "unknown (manifest.json missing)"
        DryRunMoreCandidates  = "Full candidate list is in the dry-run report. Showing first {0} of {1}."
        DryRunReadFailed      = "Dry run failed: {0} files could not be read."
        DryRunReportBackupRoot = "Backup root"
        DryRunReportCandidates = "Driver packages that would be sent to Windows"
        DryRunReportChecksumChecked = "Checksum checked"
        DryRunReportClass     = "Class"
        DryRunReportCreated   = "Dry-run report saved: {0}"
        DryRunReportCreatedAt = "Created"
        DryRunReportInfPackages = "INF packages"
        DryRunReportMachineMismatches = "Machine mismatches"
        DryRunReportMachineStatus = "Machine check"
        DryRunReportProvider  = "Provider"
        DryRunReportReadableFiles = "Readable files"
        DryRunReportReadError = "Read error"
        DryRunReportTitle     = "DriverVault dry-run restore report"
        DryRunStart           = "Dry-run restore: checking backup without installing drivers."
        ExitCode              = "Exit code: {0}"
        ExportedInfCount      = "Exported INF files: {0}"
        ExportingDrivers      = "Exporting driver packages with pnputil. This can take a few minutes."
        ExportingDriversFallback = "pnputil export failed. Trying DISM export as a fallback."
        DriverStoreFallback  = "DISM failed too. Copying driver packages directly from DriverStore."
        DriverStoreCopied    = "DriverStore packages copied: {0}"
        FoundInfCount         = "Found INF files: {0}"
        HeaderSubtitle        = "Local driver backup and restore for this PC."
        InfFiles              = "INF files: {0}"
        InspectButton         = "Details"
        InstallDrivers        = "Installing driver packages with pnputil."
        LanguageStatus        = "Language: English"
        LogTitle              = "Activity log"
        MachineLooksSame      = "Machine check: looks like the same PC."
        Machine               = "Machine: {0} {1}"
        MachineCheckUnavailable = "Machine check: manifest.json is missing, cannot compare this PC."
        MachineMismatch       = "This backup may be for another PC: {0}"
        MachineMismatchBlocked = "This backup was created for a different PC. Restore was stopped to protect this Windows installation."
        ManifestMissing       = "manifest.json was not found. Continuing with driver install."
        ManifestMissingShort  = "manifest.json was not found."
        NoInfExported         = "No INF files were exported. The system may only be using inbox Windows drivers."
        NoInfFound            = "No INF driver files were found in this backup: {0}"
        OpenFolder            = "Open"
        OsLine                = "OS: {0} {1}"
        PressEnter            = "Press Enter to close"
        InspectPathRequired   = "BackupPath is required for inspect."
        CheckRestoreButton    = "Check"
        ChecksumCreate        = "Creating SHA256 checksums for driver files."
        ChecksumCreated       = "Checksum file created: {0} files."
        ChecksumMissingFile   = "Backup folder looks damaged: missing file {0}"
        ChecksumMismatch      = "Checksum warning: hash mismatch {0}"
        ChecksumUnreadableFile = "Backup folder looks damaged: file cannot be read {0}"
        ChecksumOk            = "Checksum check passed: {0} files."
        ChecksumUnavailable   = "checksums.json was not found. Integrity check skipped."
        ChecksumValidationFailed = "Backup folder looks damaged: SHA256 check failed."
        ChecksumValidate      = "Checking driver file integrity."
        CleanupFailedBackup   = "Backup failed. Marking this folder as failed."
        CancelButton          = "Cancel"
        Canceling             = "Canceling operation..."
        DetailLogHint         = "System details are written to the log file."
        FinalBackupSummary    = "Backup ready: {0} INF, {1} files, {2} checksums."
        FinalRestoreSummary   = "Restore finished: {0} INF packages were sent to Windows."
        FinalDryRunSummary    = "Dry run passed: {0} INF packages would be added. Report: {1}"
        FinalValidateSummary  = "Check passed: {0} INF, {1} checksums."
        FullModeStart         = "Full mode: copying the complete DriverStore."
        LastBackupNone        = "none"
        OpenAfterDone         = "Folder is ready: {0}"
        OperationCanceled     = "Operation canceled."
        OldFailedRemoved      = "Removed old failed backup: {0}"
        ErrorAccessDenied     = "Windows denied access to a file or folder. Run as Administrator and make sure antivirus or another program is not blocking the backup."
        ErrorAdminRequired    = "No administrator rights. Restart DriverVault as Administrator."
        ErrorBackupDamaged    = "Backup folder looks damaged: {0}"
        ErrorBackupMetadataDamaged = "Backup folder looks damaged: {0} cannot be read."
        ErrorBackupPathMissing = "The selected backup path does not exist: {0}"
        ErrorChecksumDamaged  = "Backup folder looks damaged: SHA256 check failed. Missing files: {0}; changed files: {1}; unreadable files: {2}."
        ErrorCommandFailedFriendly = "{0} failed with exit code {1}. Check the log for technical details."
        ErrorDriverInstallFailed = "Windows could not add the driver packages. The backup may contain an unsupported or damaged driver package. Check the log for details."
        ErrorFileBusy         = "A file is busy. Close Explorer, installers, Device Manager or antivirus scanning this folder, then try again."
        ErrorPathMissing      = "A needed file or folder was not found. Check that you selected the correct DriverVault backup folder."
        ErrorUnexpected       = "Unexpected error: {0}"
        ProgressChecksum      = "SHA256: {0}/{1}"
        ProgressCopy          = "Copying packages: {0}/{1}"
        ProgressExport        = "Exported packages: {0}"
        ProgressInstall       = "Installing packages: {0}"
        ProgressReadFiles     = "Reading files: {0}/{1}"
        SimpleCheckOk         = "Pre-check is OK. Continuing."
        StatusAdmin           = "Admin"
        StatusInf             = "INF"
        StatusLast            = "Last"
        PnputilRetry          = "pnputil /enum-drivers /files failed, retrying without /files."
        Ready                 = "Ready. Choose Backup drivers before reinstalling Windows."
        RestartAsAdmin        = "Admin"
        RestoreButton         = "Restore"
        RestoreConfirm        = "Restore drivers from this folder? Windows may need a reboot after this."
        RestoreCompleted      = "Restore completed. Reboot Windows to finish driver binding."
        RestorePathRequired   = "BackupPath is required for restore."
        RestoreRequiresAdmin  = "No administrator rights. Restart DriverVault as Administrator before restore."
        RestoreRoot           = "Restore root: {0}"
        Running               = "Running: {0} {1}"
        SavingPnputil         = "Saving pnputil driver listing."
        ScriptPathUnknown     = "Cannot elevate because script path is unknown."
        Title                 = "DriverVault - backup and restore Windows drivers"
        TechnicalDetails      = "Technical details: {0}"
        ZipCheck              = "Also create a ZIP archive after backup"
        ZipCreated            = "ZIP archive created."
    }
    ru = @{
        AdminYes              = "Администратор: готово"
        AdminNo               = "Нужен запуск от администратора"
        BackupButton          = "Сохранить"
        BackupCompleted       = "Резервная копия готова."
        BackupFolder          = "Папка резервной копии:"
        BackupLooksUsable     = "Резервная копия выглядит пригодной для восстановления."
        BackupModeLabel       = "Режим:"
        BackupModeRecommended = "Рекомендуемый"
        BackupModeFull        = "Полная копия"
        BackupRequiresAdmin   = "Нет прав администратора. Перед сохранением запустите DriverVault от имени администратора."
        BackupRoot            = "Папка резервной копии: {0}"
        BrowseButton          = "Обзор"
        BrowseDescription     = "Выберите существующую папку резервной копии или папку для новой копии."
        CollectInventory      = "Собираю сведения о компьютере и список установленных драйверов."
        CommandFailed         = "{1} завершилась с ошибкой {0}. Технические подробности записаны в журнал."
        Created               = "Создано: {0}"
        CreatingZip           = "Создаю ZIP-архив: {0}"
        DriversFolderMissing  = "Папка резервной копии повреждена: не найдена папка Drivers: {0}"
        DryRunButton          = "Пробное"
        DryRunCandidate       = "Будет добавлен: {0}"
        DryRunCompleted       = "Пробное восстановление завершено. Драйверы не устанавливались."
        DryRunFileReadableOk  = "Проверка чтения файлов пройдена: {0} файлов."
        DryRunFileUnreadable  = "Файл не читается: {0}"
        DryRunMachineMismatch = "возможно другой ПК"
        DryRunMachineSame     = "тот же ПК"
        DryRunMachineUnknown  = "неизвестно (manifest.json отсутствует)"
        DryRunMoreCandidates  = "Полный список кандидатов сохранён в отчёте. Показаны первые {0} из {1}."
        DryRunReadFailed      = "Пробная проверка не пройдена: не читается файлов {0}."
        DryRunReportBackupRoot = "Папка копии"
        DryRunReportCandidates = "Пакеты драйверов, которые были бы отправлены Windows"
        DryRunReportChecksumChecked = "Проверено SHA256"
        DryRunReportClass     = "Класс"
        DryRunReportCreated   = "Отчёт пробного восстановления сохранён: {0}"
        DryRunReportCreatedAt = "Создано"
        DryRunReportInfPackages = "INF-пакетов"
        DryRunReportMachineMismatches = "Несовпадения компьютера"
        DryRunReportMachineStatus = "Проверка компьютера"
        DryRunReportProvider  = "Поставщик"
        DryRunReportReadableFiles = "Файлов читается"
        DryRunReportReadError = "Ошибка чтения"
        DryRunReportTitle     = "Отчёт пробного восстановления DriverVault"
        DryRunStart           = "Пробное восстановление: проверяю копию без установки драйверов."
        ExitCode              = "Код завершения: {0}"
        ExportedInfCount      = "Экспортировано INF-файлов: {0}"
        ExportingDrivers      = "Экспортирую драйверы через pnputil. Это может занять несколько минут."
        ExportingDriversFallback = "pnputil не смог экспортировать драйверы. Пробую запасной способ через DISM."
        DriverStoreFallback  = "DISM тоже завершился с ошибкой. Копирую пакеты драйверов напрямую из DriverStore."
        DriverStoreCopied    = "Скопировано пакетов из DriverStore: {0}"
        FoundInfCount         = "Найдено INF-файлов: {0}"
        HeaderSubtitle        = "Локальная копия драйверов и быстрое восстановление на этом ПК."
        InfFiles              = "INF-файлов: {0}"
        InspectButton         = "Сведения"
        InstallDrivers        = "Устанавливаю драйверы через pnputil."
        LanguageStatus        = "Язык: русский"
        LogTitle              = "Журнал работы"
        MachineLooksSame      = "Проверка компьютера: похоже, это тот же ПК."
        Machine               = "Компьютер: {0} {1}"
        MachineCheckUnavailable = "Проверка компьютера: manifest.json отсутствует, сравнить этот ПК нельзя."
        MachineMismatch       = "Резервная копия может быть от другого ПК: {0}"
        MachineMismatchBlocked = "Копия создана для другого ПК. Восстановление остановлено, чтобы не повредить эту Windows."
        ManifestMissing       = "manifest.json не найден. Продолжаю установку драйверов."
        ManifestMissingShort  = "manifest.json не найден."
        NoInfExported         = "INF-файлы не экспортированы. Возможно, система использует только встроенные драйверы Windows."
        NoInfFound            = "В копии нет INF-файлов драйверов: {0}"
        OpenFolder            = "Открыть"
        OsLine                = "ОС: {0} {1}"
        PressEnter            = "Нажмите Enter, чтобы закрыть"
        InspectPathRequired   = "Для проверки укажите BackupPath."
        CheckRestoreButton    = "Проверить"
        ChecksumCreate        = "Создаю SHA256-контрольные суммы файлов драйверов."
        ChecksumCreated       = "Файл контрольных сумм создан: {0} файлов."
        ChecksumMissingFile   = "Папка резервной копии повреждена: отсутствует файл {0}"
        ChecksumMismatch      = "Предупреждение SHA256: хэш не совпадает {0}"
        ChecksumUnreadableFile = "Папка резервной копии повреждена: файл не читается {0}"
        ChecksumOk            = "Проверка SHA256 пройдена: {0} файлов."
        ChecksumUnavailable   = "checksums.json не найден. Проверка целостности пропущена."
        ChecksumValidationFailed = "Папка резервной копии повреждена: проверка SHA256 не прошла."
        ChecksumValidate      = "Проверяю целостность файлов драйверов."
        CleanupFailedBackup   = "Сохранение сорвалось. Помечаю эту папку как неудачную."
        CancelButton          = "Отмена"
        Canceling             = "Отменяю операцию..."
        DetailLogHint         = "Системные подробности записываются в файл журнала."
        FinalBackupSummary    = "Копия готова: INF {0}, файлов {1}, SHA256 {2}."
        FinalRestoreSummary   = "Восстановление завершено: Windows получила {0} INF-пакетов."
        FinalDryRunSummary    = "Пробная проверка пройдена: будет добавлено INF {0}. Отчёт: {1}"
        FinalValidateSummary  = "Проверка пройдена: INF {0}, SHA256 {1}."
        FullModeStart         = "Полный режим: копирую весь DriverStore."
        LastBackupNone        = "нет"
        OpenAfterDone         = "Папка готова: {0}"
        OperationCanceled     = "Операция отменена."
        OldFailedRemoved      = "Удалена старая неудачная копия: {0}"
        ErrorAccessDenied     = "Windows запретила доступ к файлу или папке. Запустите от имени администратора и проверьте, что антивирус или другая программа не блокирует копию."
        ErrorAdminRequired    = "Нет прав администратора. Перезапустите DriverVault от имени администратора."
        ErrorBackupDamaged    = "Папка резервной копии повреждена: {0}"
        ErrorBackupMetadataDamaged = "Папка резервной копии повреждена: не читается {0}."
        ErrorBackupPathMissing = "Выбранная папка резервной копии не существует: {0}"
        ErrorChecksumDamaged  = "Папка резервной копии повреждена: проверка SHA256 не прошла. Отсутствует файлов: {0}; изменено файлов: {1}; не читается файлов: {2}."
        ErrorCommandFailedFriendly = "{0} завершилась с ошибкой {1}. Технические подробности записаны в журнал."
        ErrorDriverInstallFailed = "Windows не смогла добавить пакеты драйверов. Возможно, в копии есть неподдерживаемый или повреждённый пакет. Подробности записаны в журнал."
        ErrorFileBusy         = "Файл занят. Закройте Проводник, установщики, Диспетчер устройств или проверку антивируса для этой папки и повторите."
        ErrorPathMissing      = "Нужный файл или папка не найдены. Проверьте, что выбрана правильная папка резервной копии DriverVault."
        ErrorUnexpected       = "Неожиданная ошибка: {0}"
        ProgressChecksum      = "SHA256: {0}/{1}"
        ProgressCopy          = "Копирую пакеты: {0}/{1}"
        ProgressExport        = "Экспортировано пакетов: {0}"
        ProgressInstall       = "Установлено пакетов: {0}"
        ProgressReadFiles     = "Читаю файлы: {0}/{1}"
        SimpleCheckOk         = "Предварительная проверка OK. Продолжаю."
        StatusAdmin           = "Админ"
        StatusInf             = "INF"
        StatusLast            = "Последняя"
        PnputilRetry          = "pnputil /enum-drivers /files завершился с ошибкой, повторяю без /files."
        Ready                 = "Готово. Перед переустановкой Windows нажмите «Сохранить драйверы»."
        RestartAsAdmin        = "Админ"
        RestoreButton         = "Восстановить"
        RestoreConfirm        = "Восстановить драйверы из этой папки? После этого Windows может потребовать перезагрузку."
        RestoreCompleted      = "Восстановление завершено. Перезагрузите Windows, чтобы драйверы окончательно применились."
        RestorePathRequired   = "Для восстановления укажите BackupPath."
        RestoreRequiresAdmin  = "Нет прав администратора. Перед восстановлением запустите DriverVault от имени администратора."
        RestoreRoot           = "Папка восстановления: {0}"
        Running               = "Запуск: {0} {1}"
        SavingPnputil         = "Сохраняю список драйверов pnputil."
        ScriptPathUnknown     = "Не удалось перезапуститься с правами администратора: неизвестен путь к скрипту."
        Title                 = "DriverVault - сохранение и восстановление драйверов Windows"
        TechnicalDetails      = "Технические подробности: {0}"
        ZipCheck              = "Также создать ZIP-архив после сохранения"
        ZipCreated            = "ZIP-архив создан."
    }
}

function T {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [object[]]$Args = @()
    )

    $value = $script:Strings[$script:UiLanguage][$Key]
    if (-not $value) {
        $value = $script:Strings.en[$Key]
    }
    if (-not $value) {
        return $Key
    }
    if ($Args.Count -gt 0) {
        return ($value -f $Args)
    }
    return $value
}

function Set-DriverVaultStatus {
    param([string]$Text)

    if ($script:GuiStatusLabel) {
        $script:GuiStatusLabel.Text = $Text
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Set-DriverVaultProgress {
    param(
        [string]$Activity,
        [int]$Current = -1,
        [int]$Total = 0
    )

    $status = $Activity
    if ($Current -ge 0 -and $Total -gt 0) {
        $status = "{0} ({1}/{2})" -f $Activity, $Current, $Total
    }
    elseif ($Current -ge 0) {
        $status = "{0} ({1})" -f $Activity, $Current
    }

    Set-DriverVaultStatus $status

    if ($script:GuiProgressBar) {
        if ($Total -gt 0) {
            $script:GuiProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
            $script:GuiProgressBar.Minimum = 0
            $script:GuiProgressBar.Maximum = [Math]::Max(1, $Total)
            $script:GuiProgressBar.Value = [Math]::Min([Math]::Max(0, $Current), $script:GuiProgressBar.Maximum)
        }
        else {
            $script:GuiProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        }
        $script:GuiProgressBar.Visible = $true
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Reset-DriverVaultProgress {
    if ($script:GuiProgressBar) {
        $script:GuiProgressBar.Visible = $false
        $script:GuiProgressBar.Value = 0
    }
}

function Request-DriverVaultCancel {
    $script:CancelRequested = $true
    Set-DriverVaultStatus (T "Canceling")
    if ($script:CurrentProcess -and -not $script:CurrentProcess.HasExited) {
        try {
            $script:CurrentProcess.Kill()
        }
        catch {
            Write-DriverVaultLog $_.Exception.Message "WARN"
        }
    }
}

function Test-DriverVaultCancel {
    if ($script:CancelRequested) {
        throw (T "OperationCanceled")
    }
}

function Show-DriverVaultSummary {
    param([object]$Summary)

    if (-not $Summary) {
        return
    }

    $text = [string]$Summary.Message
    if ([string]::IsNullOrWhiteSpace($text)) {
        return
    }

    Write-DriverVaultLog $text "OK"
    if ($script:GuiSummaryLabel) {
        $script:GuiSummaryLabel.Text = $text
        $script:GuiSummaryLabel.ForeColor = [System.Drawing.Color]::FromArgb(50, 213, 131)
    }
    if ($script:GuiInfValueLabel -and $Summary.InfCount -ne $null) {
        $script:GuiInfValueLabel.Text = [string]$Summary.InfCount
    }
    if ($script:GuiLastValueLabel -and $Summary.Root) {
        $script:GuiLastValueLabel.Text = Split-Path -Leaf ([string]$Summary.Root)
    }
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SafeName {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "Unknown"
    }

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $chars = $Value.ToCharArray() | ForEach-Object {
        if ($invalid -contains $_) { "_" } else { $_ }
    }
    return (($chars -join "") -replace "\s+", "_")
}

function Test-IsUsefulHardwareValue {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    $normalized = $Value.Trim()
    $badValues = @(
        "System manufacturer",
        "System Product Name",
        "To be filled by O.E.M.",
        "To Be Filled By O.E.M.",
        "Default string",
        "Default",
        "None",
        "Unknown",
        "Not Applicable",
        "N/A"
    )

    return -not ($badValues -contains $normalized)
}

function Get-BackupMachineName {
    param([hashtable]$Identity)

    $candidatePairs = @(
        @($Identity.Manufacturer, $Identity.Model),
        @($Identity.BaseBoardManufacturer, $Identity.BaseBoardProduct)
    )

    foreach ($pair in $candidatePairs) {
        $left = [string]$pair[0]
        $right = [string]$pair[1]
        if ((Test-IsUsefulHardwareValue $left) -and (Test-IsUsefulHardwareValue $right)) {
            return (Get-SafeName ("{0}_{1}" -f $left, $right))
        }
    }

    if (Test-IsUsefulHardwareValue $env:COMPUTERNAME) {
        return (Get-SafeName $env:COMPUTERNAME)
    }

    return "This_PC"
}

function Write-DriverVaultLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "OK")]
        [string]$Level = "INFO",
        [switch]$Detail
    )

    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    if (-not $script:GuiMode) {
        Write-Host $line
    }

    if ($script:LogFile) {
        $logDir = Split-Path -Parent $script:LogFile
        if (-not (Test-Path -LiteralPath $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8
    }

    if ($script:GuiLogBox -and -not $Detail) {
        $script:GuiLogBox.AppendText($line + [Environment]::NewLine)
        $script:GuiLogBox.SelectionStart = $script:GuiLogBox.TextLength
        $script:GuiLogBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Test-DriverVaultTextMatch {
    param(
        [string]$Text,
        [string[]]$Patterns
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) {
            return $true
        }
    }

    return $false
}

function Get-FriendlyNativeCommandError {
    param(
        [string]$FilePath,
        [int]$ExitCode,
        [object[]]$Output,
        [string]$FailureContext = "Command"
    )

    $toolName = Split-Path -Leaf $FilePath
    $text = (@($Output) -join "`n")

    if ($ExitCode -eq 740 -or (Test-DriverVaultTextMatch $text @("(?i)administrator", "(?i)elevat", "Запрошенная операция требует повышения", "администратор"))) {
        return (T "ErrorAdminRequired")
    }

    if (Test-DriverVaultTextMatch $text @("(?i)being used by another process", "(?i)process cannot access", "(?i)sharing violation", "используется другим процессом", "занят", "0x80070020")) {
        return (T "ErrorFileBusy")
    }

    if (Test-DriverVaultTextMatch $text @("(?i)access is denied", "(?i)access denied", "Отказано в доступе", "доступ запрещ")) {
        return (T "ErrorAccessDenied")
    }

    if ($FailureContext -eq "RestoreInstall") {
        return (T "ErrorDriverInstallFailed")
    }

    return (T "ErrorCommandFailedFriendly" $toolName, $ExitCode)
}

function Get-FriendlyExceptionMessage {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $exception = $ErrorRecord.Exception
    $message = [string]$exception.Message
    if ([string]::IsNullOrWhiteSpace($message)) {
        return (T "ErrorUnexpected" "")
    }

    if ($exception -is [System.Management.Automation.RuntimeException] -and $exception.WasThrownFromThrowStatement) {
        return $message
    }

    if ($exception -is [UnauthorizedAccessException] -or [System.Security.SecurityException]::IsAssignableFrom($exception.GetType()) -or
        (Test-DriverVaultTextMatch $message @("(?i)access is denied", "(?i)access denied", "Отказано в доступе", "доступ запрещ"))) {
        return (T "ErrorAccessDenied")
    }

    if ($exception -is [IO.IOException] -and
        (Test-DriverVaultTextMatch $message @("(?i)being used by another process", "(?i)process cannot access", "(?i)sharing violation", "используется другим процессом", "занят", "0x80070020"))) {
        return (T "ErrorFileBusy")
    }

    if ($exception -is [IO.DirectoryNotFoundException] -or $exception -is [IO.FileNotFoundException] -or
        (Test-DriverVaultTextMatch $message @("(?i)could not find", "(?i)cannot find", "не удается найти", "не найден"))) {
        return (T "ErrorPathMissing")
    }

    if (Test-DriverVaultTextMatch $message @("(?i)ConvertFrom-Json", "(?i)invalid json", "(?i)unexpected character", "Недопустим", "не является допустимым JSON")) {
        return (T "ErrorBackupDamaged" $message)
    }

    return $message
}

function Write-FriendlyCaughtError {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $friendly = Get-FriendlyExceptionMessage -ErrorRecord $ErrorRecord
    $raw = [string]$ErrorRecord.Exception.Message
    Write-DriverVaultLog $friendly "ERROR"

    if ($raw -and $raw -ne $friendly) {
        Write-DriverVaultLog (T "TechnicalDetails" $raw) "WARN" -Detail
    }

    return $friendly
}

function Join-NativeArgumentList {
    param([string[]]$ArgumentList)

    $quoted = foreach ($argument in $ArgumentList) {
        $safeArgument = $argument -replace '%', '%%'
        if ($safeArgument -match '[\s"&|<>()^]') {
            '"' + ($safeArgument -replace '"', '\"') + '"'
        }
        else {
            $safeArgument
        }
    }
    return ($quoted -join " ")
}

function Get-SystemToolPath {
    param([Parameter(Mandatory = $true)][string]$FileName)

    if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
        $sysnativePath = Join-Path $env:SystemRoot ("Sysnative\{0}" -f $FileName)
        if (Test-Path -LiteralPath $sysnativePath) {
            return $sysnativePath
        }
    }

    return (Join-Path $env:SystemRoot ("System32\{0}" -f $FileName))
}

function Get-DriverVaultAssetPath {
    param([string]$Name)

    $root = if ($PSScriptRoot) {
        $PSScriptRoot
    }
    elseif ($PSCommandPath) {
        Split-Path -Parent $PSCommandPath
    }
    else {
        (Get-Location).Path
    }

    return (Join-Path $root ("assets\{0}" -f $Name))
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [ValidateSet("None", "Export", "Install")]
        [string]$ProgressKind = "None",

        [string]$FailureContext = "Command",

        [switch]$ThrowOnError
    )

    Write-DriverVaultLog (T "Running" $FilePath, ($ArgumentList -join " "))

    $stdoutFile = Join-Path $env:TEMP ("DriverVault_stdout_{0}.log" -f ([guid]::NewGuid().ToString("N")))
    $stderrFile = Join-Path $env:TEMP ("DriverVault_stderr_{0}.log" -f ([guid]::NewGuid().ToString("N")))
    $batchFile = Join-Path $env:TEMP ("DriverVault_run_{0}.cmd" -f ([guid]::NewGuid().ToString("N")))
    $output = New-Object System.Collections.Generic.List[string]
    $stdoutLength = 0
    $stderrLength = 0
    $progressCount = 0
    $exitCode = 1
    $wasCanceled = $false

    function Read-NewCommandLines {
        param(
            [string]$Path,
            [ref]$LastLength
        )

        if (-not (Test-Path -LiteralPath $Path)) {
            return
        }

        try {
            $bytes = [IO.File]::ReadAllBytes($Path)
        }
        catch {
            return
        }
        if ($bytes.Length -le $LastLength.Value) {
            return
        }

        $chunk = $script:NativeOutputEncoding.GetString($bytes, $LastLength.Value, $bytes.Length - $LastLength.Value)
        $LastLength.Value = $bytes.Length
        foreach ($line in ($chunk -split "\r?\n")) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            [void]$output.Add($line)
            Write-DriverVaultLog $line "INFO" -Detail

            if ($ProgressKind -eq "Export" -and $line -match '(?i)Exporting driver package') {
                $script:__DriverVaultProgressCount++
                Set-DriverVaultProgress (T "ProgressExport" $script:__DriverVaultProgressCount) $script:__DriverVaultProgressCount
            }
            elseif ($ProgressKind -eq "Install" -and $line -match '(?i)(Adding driver package|Driver package added|Published Name|Опубликованное имя)') {
                $script:__DriverVaultProgressCount++
                Set-DriverVaultProgress (T "ProgressInstall" $script:__DriverVaultProgressCount) $script:__DriverVaultProgressCount
            }
        }
    }

    try {
        $script:__DriverVaultProgressCount = 0
        $nativeCommand = '"{0}" {1} > "{2}" 2> "{3}"' -f $FilePath, (Join-NativeArgumentList -ArgumentList $ArgumentList), $stdoutFile, $stderrFile
        [IO.File]::WriteAllLines($batchFile, @(
            "@echo off",
            $nativeCommand,
            "exit /b %ERRORLEVEL%"
        ), [Text.Encoding]::ASCII)

        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = (Get-SystemToolPath "cmd.exe")
        $processInfo.Arguments = ('/d /c "{0}"' -f $batchFile)
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        [void]$process.Start()
        $script:CurrentProcess = $process

        while (-not $process.HasExited) {
            Read-NewCommandLines -Path $stdoutFile -LastLength ([ref]$stdoutLength)
            Read-NewCommandLines -Path $stderrFile -LastLength ([ref]$stderrLength)
            if ($script:CancelRequested) {
                $wasCanceled = $true
                try { $process.Kill() } catch { }
                break
            }
            Start-Sleep -Milliseconds 250
            if ($script:GuiLogBox) {
                [System.Windows.Forms.Application]::DoEvents()
            }
        }
        $process.WaitForExit()
        $exitCode = [int]$process.ExitCode
        Read-NewCommandLines -Path $stdoutFile -LastLength ([ref]$stdoutLength)
        Read-NewCommandLines -Path $stderrFile -LastLength ([ref]$stderrLength)
    }
    finally {
        $script:CurrentProcess = $null
        Remove-Item -LiteralPath $stdoutFile, $stderrFile, $batchFile -Force -ErrorAction SilentlyContinue
        Remove-Variable -Name __DriverVaultProgressCount -Scope Script -ErrorAction SilentlyContinue
    }

    if ($wasCanceled) {
        throw (T "OperationCanceled")
    }

    if ($output.Count -eq 0 -and $exitCode -ne 0) {
        foreach ($line in @(
            "No command output was captured.",
            "Run path: $FilePath",
            "Arguments: $($ArgumentList -join ' ')"
        )) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                [void]$output.Add($line)
                Write-DriverVaultLog $line "WARN"
            }
        }
    }

    Write-DriverVaultLog (T "ExitCode" $exitCode)

    if ($ThrowOnError -and $exitCode -ne 0) {
        throw (Get-FriendlyNativeCommandError -FilePath $FilePath -ExitCode $exitCode -Output @($output) -FailureContext $FailureContext)
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = @($output)
        Failure  = if ($exitCode -ne 0) { Get-FriendlyNativeCommandError -FilePath $FilePath -ExitCode $exitCode -Output @($output) -FailureContext $FailureContext } else { "" }
    }
}

function Copy-DriverStoreFallback {
    param([string]$DriversDir)

    $source = Join-Path $env:SystemRoot "System32\DriverStore\FileRepository"
    if (-not (Test-Path -LiteralPath $source)) {
        throw "DriverStore FileRepository was not found: $source"
    }

    $packages = @(Get-ChildItem -LiteralPath $source -Directory -ErrorAction Stop)
    $total = [Math]::Max(1, $packages.Count)
    $copied = 0
    $seen = 0
    foreach ($package in $packages) {
        Test-DriverVaultCancel
        $seen++
        $hasInf = Get-ChildItem -LiteralPath $package.FullName -Filter "*.inf" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hasInf -and $package.Name -match '_(amd64|x86|arm64)_') {
            $destination = Join-Path $DriversDir $package.Name
            if (Test-Path -LiteralPath $destination) {
                Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction Stop
            }
            Copy-Item -LiteralPath $package.FullName -Destination $destination -Recurse -Force -ErrorAction Stop
            $copied++
            if (($copied % 20) -eq 0 -or $seen -eq $packages.Count) {
                Set-DriverVaultProgress (T "ProgressCopy" $copied, $packages.Count) $seen $total
                Write-DriverVaultLog (T "DriverStoreCopied" $copied)
            }
        }
    }

    Write-DriverVaultLog (T "DriverStoreCopied" $copied) "OK"
    return $copied
}

function Invoke-DriverExport {
    param(
        [string]$DriversDir,
        [ValidateSet("Recommended", "Full")]
        [string]$Scope = "Recommended"
    )

    if ($Scope -eq "Full") {
        Write-DriverVaultLog (T "FullModeStart")
        $copied = Copy-DriverStoreFallback -DriversDir $DriversDir
        return [pscustomobject]@{
            ExitCode = 0
            Method   = "DriverStore"
            Output   = @("DriverStore packages copied: $copied")
        }
    }

    Write-DriverVaultLog (T "ExportingDrivers")
    $pnputilExport = Invoke-LoggedCommand -FilePath (Get-SystemToolPath "pnputil.exe") -ArgumentList @(
        "/export-driver",
        "*",
        $DriversDir
    ) -ProgressKind "Export"

    if ($pnputilExport.ExitCode -eq 0) {
        $pnputilExport | Add-Member -NotePropertyName Method -NotePropertyValue "pnputil" -Force
        return $pnputilExport
    }

    Write-DriverVaultLog (T "ExportingDriversFallback") "WARN"
    $dismExport = Invoke-LoggedCommand -FilePath (Get-SystemToolPath "dism.exe") -ArgumentList @(
        "/Online",
        "/Export-Driver",
        "/Destination:$DriversDir"
    )

    if ($dismExport.ExitCode -eq 0) {
        $dismExport | Add-Member -NotePropertyName Method -NotePropertyValue "DISM" -Force
        return $dismExport
    }

    Write-DriverVaultLog (T "DriverStoreFallback") "WARN"
    $copied = Copy-DriverStoreFallback -DriversDir $DriversDir
    if ($copied -le 0) {
        throw (T "ErrorCommandFailedFriendly" "DriverStore copy fallback", 1)
    }

    return [pscustomobject]@{
        ExitCode = 0
        Method   = "DriverStore"
        Output   = @("DriverStore packages copied: $copied")
    }
}

function Get-MachineIdentity {
    $computer = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $baseBoard = Get-CimInstance Win32_BaseBoard
    $os = Get-CimInstance Win32_OperatingSystem

    return [ordered]@{
        ComputerName         = $env:COMPUTERNAME
        Manufacturer         = $computer.Manufacturer
        Model                = $computer.Model
        SystemType           = $computer.SystemType
        BIOSSerialNumber     = $bios.SerialNumber
        BIOSVersion          = ($bios.SMBIOSBIOSVersion -join "; ")
        BaseBoardManufacturer = $baseBoard.Manufacturer
        BaseBoardProduct     = $baseBoard.Product
        BaseBoardSerial      = $baseBoard.SerialNumber
        OSName               = $os.Caption
        OSVersion            = $os.Version
        OSArchitecture       = $os.OSArchitecture
    }
}

function Get-DriverInventory {
    Get-CimInstance Win32_PnPSignedDriver |
        Select-Object DeviceName, Manufacturer, DriverProviderName, DriverVersion,
            DriverDate, InfName, IsSigned, DeviceClass, DeviceID |
        Sort-Object DeviceName, InfName
}

function New-DefaultBackupPath {
    $identity = Get-MachineIdentity
    $identityHash = @{}
    foreach ($key in $identity.Keys) {
        $identityHash[$key] = $identity[$key]
    }
    $model = Get-BackupMachineName -Identity $identityHash
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    return Join-Path ([Environment]::GetFolderPath("Desktop")) ("DriverVault_{0}_{1}" -f $model, $stamp)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $InputObject | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Read-DriverVaultJsonFile {
    param([string]$Path)

    try {
        return (Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        throw (T "ErrorBackupMetadataDamaged" (Split-Path -Leaf $Path))
    }
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$Path
    )

    $baseFull = [IO.Path]::GetFullPath($BasePath).TrimEnd('\') + '\'
    $pathFull = [IO.Path]::GetFullPath($Path)
    $baseUri = New-Object Uri($baseFull)
    $pathUri = New-Object Uri($pathFull)
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('/', '\')
}

function Get-DriverBackupFiles {
    param([string]$DriversDir)

    if (-not (Test-Path -LiteralPath $DriversDir)) {
        return @()
    }

    return @(Get-ChildItem -LiteralPath $DriversDir -File -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName)
}

function New-DriverChecksumFile {
    param(
        [string]$Root,
        [string]$DriversDir
    )

    Write-DriverVaultLog (T "ChecksumCreate")
    $files = @(Get-DriverBackupFiles -DriversDir $DriversDir)
    $total = [Math]::Max(1, $files.Count)
    $index = 0
    $checksums = foreach ($file in $files) {
        Test-DriverVaultCancel
        $index++
        if (($index % 50) -eq 0 -or $index -eq $files.Count) {
            Set-DriverVaultProgress (T "ProgressChecksum" $index, $files.Count) $index $total
        }
        $hash = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256
        [ordered]@{
            RelativePath     = Get-RelativePath -BasePath $Root -Path $file.FullName
            Length           = $file.Length
            LastWriteTimeUtc = $file.LastWriteTimeUtc.ToString("o")
            SHA256           = $hash.Hash
        }
    }

    Write-JsonFile -InputObject $checksums -Path (Join-Path $Root "checksums.json")
    Write-DriverVaultLog (T "ChecksumCreated" @($checksums).Count) "OK"
    return @($checksums)
}

function Test-DriverChecksumFile {
    param([string]$Root)

    $checksumPath = Join-Path $Root "checksums.json"
    if (-not (Test-Path -LiteralPath $checksumPath)) {
        Write-DriverVaultLog (T "ChecksumUnavailable") "WARN"
        return [pscustomobject]@{ Present = $false; Checked = 0; Missing = 0; Mismatch = 0; Unreadable = 0; IsValid = $true }
    }

    Write-DriverVaultLog (T "ChecksumValidate")
    $entries = Read-DriverVaultJsonFile -Path $checksumPath
    $entries = @($entries)
    $checked = 0
    $missing = 0
    $mismatch = 0
    $unreadable = 0

    foreach ($entry in $entries) {
        Test-DriverVaultCancel
        $path = Join-Path $Root ([string]$entry.RelativePath)
        if (-not (Test-Path -LiteralPath $path)) {
            $missing++
            Write-DriverVaultLog (T "ChecksumMissingFile" $entry.RelativePath) "WARN"
            continue
        }

        $checked++
        if (($checked % 50) -eq 0 -or $checked -eq $entries.Count) {
            Set-DriverVaultProgress (T "ProgressChecksum" $checked, $entries.Count) $checked ([Math]::Max(1, $entries.Count))
        }
        try {
            $hash = Get-FileHash -LiteralPath $path -Algorithm SHA256 -ErrorAction Stop
        }
        catch {
            $unreadable++
            Write-DriverVaultLog (T "ChecksumUnreadableFile" $entry.RelativePath) "WARN"
            continue
        }
        if ($hash.Hash -ne $entry.SHA256) {
            $mismatch++
            Write-DriverVaultLog (T "ChecksumMismatch" $entry.RelativePath) "WARN"
        }
    }

    if ($missing -eq 0 -and $mismatch -eq 0 -and $unreadable -eq 0) {
        Write-DriverVaultLog (T "ChecksumOk" $checked) "OK"
    }

    return [pscustomobject]@{
        Present    = $true
        Checked    = $checked
        Missing    = $missing
        Mismatch   = $mismatch
        Unreadable = $unreadable
        IsValid    = ($missing -eq 0 -and $mismatch -eq 0 -and $unreadable -eq 0)
    }
}

function Copy-SelfIntoBackup {
    param([string]$Root)

    if ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) {
        Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $Root "DriverVault.ps1") -Force
    }

    if ($script:UiLanguage -eq "ru") {
        $restoreCmd = @"
@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DriverVault.ps1" -Mode Restore -BackupPath "%~dp0" -Language ru
echo.
echo Komanda vosstanovleniya zavershena. Proverte papku Logs i perezagruzite Windows, esli draivery byli ustanovleny.
pause
"@
    }
    else {
        $restoreCmd = @"
@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DriverVault.ps1" -Mode Restore -BackupPath "%~dp0" -Language en
echo.
echo Restore command finished. Review the log folder and reboot Windows if drivers were installed.
pause
"@
    }
    Set-Content -LiteralPath (Join-Path $Root "RESTORE_DRIVERS.cmd") -Value $restoreCmd -Encoding ASCII
}

function Mark-FailedBackup {
    param(
        [string]$Root,
        [string]$Message
    )

    try {
        if (-not (Test-Path -LiteralPath $Root)) {
            return
        }

        $marker = Join-Path $Root "FAILED_DO_NOT_USE.txt"
        @(
            "DriverVault backup failed.",
            "Time: $((Get-Date).ToString('o'))",
            "Reason: $Message"
        ) | Set-Content -LiteralPath $marker -Encoding UTF8
        Write-DriverVaultLog (T "CleanupFailedBackup") "WARN"
    }
    catch {
        Write-DriverVaultLog $_.Exception.Message "WARN"
    }
}

function Get-LatestBackupDisplayName {
    $desktop = [Environment]::GetFolderPath("Desktop")
    $latest = Get-ChildItem -LiteralPath $desktop -Directory -Filter "DriverVault_*" -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "manifest.json") } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) {
        return (T "LastBackupNone")
    }

    return $latest.LastWriteTime.ToString("dd.MM HH:mm")
}

function Remove-OldFailedBackups {
    $desktop = [Environment]::GetFolderPath("Desktop")
    $cutoff = (Get-Date).AddDays(-7)
    $failed = Get-ChildItem -LiteralPath $desktop -Directory -Filter "DriverVault_*" -ErrorAction SilentlyContinue |
        Where-Object {
            $_.LastWriteTime -lt $cutoff -and
            (Test-Path -LiteralPath (Join-Path $_.FullName "FAILED_DO_NOT_USE.txt"))
        }

    foreach ($folder in $failed) {
        try {
            Remove-Item -LiteralPath $folder.FullName -Recurse -Force -ErrorAction Stop
            Write-DriverVaultLog (T "OldFailedRemoved" $folder.FullName)
        }
        catch {
            Write-DriverVaultLog $_.Exception.Message "WARN"
        }
    }
}

function Export-DriverBackup {
    param(
        [string]$Path,
        [switch]$Zip,
        [ValidateSet("Recommended", "Full")]
        [string]$Scope = "Recommended"
    )

    if (-not (Test-IsAdministrator)) {
        throw (T "BackupRequiresAdmin")
    }

    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Path = New-DefaultBackupPath
    }

    $root = [IO.Path]::GetFullPath($Path)
    $driversDir = Join-Path $root "Drivers"
    $logsDir = Join-Path $root "Logs"

    try {
        Test-DriverVaultCancel
        Remove-OldFailedBackups
        New-Item -ItemType Directory -Path $driversDir, $logsDir -Force | Out-Null
        $script:LogFile = Join-Path $logsDir ("backup_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

        Write-DriverVaultLog (T "BackupRoot" $root)
        Write-DriverVaultLog (T "CollectInventory")
        Set-DriverVaultProgress (T "CollectInventory")

        $identity = Get-MachineIdentity
        $inventory = @(Get-DriverInventory)
        Write-JsonFile -InputObject $identity -Path (Join-Path $root "machine.json")
        Write-JsonFile -InputObject $inventory -Path (Join-Path $root "installed-drivers.json")
        $inventory | Export-Csv -LiteralPath (Join-Path $root "installed-drivers.csv") -NoTypeInformation -Encoding UTF8

        $exportResult = Invoke-DriverExport -DriversDir $driversDir -Scope $Scope

        Write-DriverVaultLog (T "SavingPnputil")
        $pnputilWithFiles = Invoke-LoggedCommand -FilePath (Get-SystemToolPath "pnputil.exe") -ArgumentList @(
            "/enum-drivers",
            "/files"
        )

        if ($pnputilWithFiles.ExitCode -ne 0) {
            Write-DriverVaultLog (T "PnputilRetry") "WARN"
            $pnputilWithFiles = Invoke-LoggedCommand -FilePath (Get-SystemToolPath "pnputil.exe") -ArgumentList @(
                "/enum-drivers"
            )
        }

        $pnputilWithFiles.Output | Set-Content -LiteralPath (Join-Path $root "pnputil-enum-drivers.txt") -Encoding UTF8

        $infFiles = @(Get-ChildItem -LiteralPath $driversDir -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue)
        $allFiles = @(Get-DriverBackupFiles -DriversDir $driversDir)
        $checksums = @(New-DriverChecksumFile -Root $root -DriversDir $driversDir)
        $manifest = [ordered]@{
            ToolName             = $script:AppName
            ToolVersion          = "1.1"
            Language             = $script:UiLanguage
            CreatedAt            = (Get-Date).ToString("o")
            BackupRoot           = $root
            DriversFolder        = "Drivers"
            BackupScope          = $Scope
            ExportMethod         = $exportResult.Method
            ExportedInfCount     = $infFiles.Count
            ExportedFileCount    = $allFiles.Count
            ChecksumFile         = "checksums.json"
            ChecksumFileCount    = $checksums.Count
            Status               = "OK"
            Machine              = $identity
            Notes                = @(
                "Recommended mode exports third-party packages from the Windows driver store.",
                "Full mode copies driver packages directly from DriverStore.",
                "Restore with RESTORE_DRIVERS.cmd or DriverVault.ps1 -Mode Restore -BackupPath <folder>.",
                "Reboot Windows after restore."
            )
        }
        Write-JsonFile -InputObject $manifest -Path (Join-Path $root "manifest.json")
        Copy-SelfIntoBackup -Root $root

        if ($infFiles.Count -eq 0) {
            Write-DriverVaultLog (T "NoInfExported") "WARN"
        }
        else {
            Write-DriverVaultLog (T "ExportedInfCount" $infFiles.Count) "OK"
        }

        if ($Zip) {
            Test-DriverVaultCancel
            $zipPath = "$root.zip"
            if (Test-Path -LiteralPath $zipPath) {
                Remove-Item -LiteralPath $zipPath -Force
            }
            Write-DriverVaultLog (T "CreatingZip" $zipPath)
            Set-DriverVaultProgress (T "CreatingZip" $zipPath)
            Compress-Archive -LiteralPath $root -DestinationPath $zipPath -CompressionLevel Optimal
            Write-DriverVaultLog (T "ZipCreated") "OK"
        }

        Write-DriverVaultLog (T "BackupCompleted") "OK"
        Write-DriverVaultLog (T "OpenAfterDone" $root)
        return [pscustomobject]@{
            Operation     = "Backup"
            Root          = $root
            InfCount      = $infFiles.Count
            FileCount     = $allFiles.Count
            ChecksumCount = $checksums.Count
            Scope         = $Scope
            Method        = $exportResult.Method
            Message       = T "FinalBackupSummary" $infFiles.Count, $allFiles.Count, $checksums.Count
        }
    }
    catch {
        Mark-FailedBackup -Root $root -Message $_.Exception.Message
        throw
    }
}

function Compare-MachineIdentity {
    param([hashtable]$SavedMachine)

    $current = Get-MachineIdentity
    $checks = @(
        "Manufacturer",
        "Model",
        "BaseBoardProduct"
    )

    $mismatches = @()
    foreach ($name in $checks) {
        $savedValue = [string]$SavedMachine[$name]
        $currentValue = [string]$current[$name]
        if ($savedValue -and $currentValue -and $savedValue -ne $currentValue) {
            $mismatches += ("{0}: backup='{1}', current='{2}'" -f $name, $savedValue, $currentValue)
        }
    }

    return $mismatches
}

function Get-BackupMachineMismatches {
    param([string]$Root)

    $manifestPath = Join-Path $Root "manifest.json"
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        Write-DriverVaultLog (T "ManifestMissingShort") "WARN"
        return @()
    }

    $manifest = Read-DriverVaultJsonFile -Path $manifestPath
    if (-not $manifest.Machine) {
        throw (T "ErrorBackupMetadataDamaged" "manifest.json")
    }

    $savedMachine = @{}
    foreach ($prop in $manifest.Machine.PSObject.Properties) {
        $savedMachine[$prop.Name] = $prop.Value
    }
    return @(Compare-MachineIdentity -SavedMachine $savedMachine)
}

function Test-DriverBackup {
    param(
        [string]$Path,
        [switch]$StopOnMachineMismatch
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw (T "InspectPathRequired")
    }

    $root = [IO.Path]::GetFullPath($Path)
    $driversDir = Join-Path $root "Drivers"
    $manifestPath = Join-Path $root "manifest.json"

    if (-not (Test-Path -LiteralPath $root)) {
        throw (T "ErrorBackupPathMissing" $root)
    }

    if (-not (Test-Path -LiteralPath $driversDir)) {
        throw (T "DriversFolderMissing" $driversDir)
    }

    $infFiles = @(Get-ChildItem -LiteralPath $driversDir -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue)
    Write-DriverVaultLog (T "BackupRoot" $root)
    Write-DriverVaultLog (T "FoundInfCount" $infFiles.Count)

    if ($infFiles.Count -eq 0) {
        throw (T "NoInfFound" $driversDir)
    }

    $mismatches = @()
    $machineStatus = "Unknown"
    $manifestPresent = Test-Path -LiteralPath $manifestPath
    if ($manifestPresent) {
        $mismatches = @(Get-BackupMachineMismatches -Root $root)
        if ($mismatches.Count -eq 0) {
            $machineStatus = "Same"
            Write-DriverVaultLog (T "MachineLooksSame") "OK"
        }
        else {
            $machineStatus = "Mismatch"
            foreach ($mismatch in $mismatches) {
                Write-DriverVaultLog (T "MachineMismatch" $mismatch) "WARN"
            }
            if ($StopOnMachineMismatch) {
                throw (T "MachineMismatchBlocked")
            }
        }
    }
    else {
        Write-DriverVaultLog (T "MachineCheckUnavailable") "WARN"
    }

    $checksumResult = Test-DriverChecksumFile -Root $root
    if (-not $checksumResult.IsValid) {
        throw (T "ErrorChecksumDamaged" $checksumResult.Missing, $checksumResult.Mismatch, $checksumResult.Unreadable)
    }

    Write-DriverVaultLog (T "BackupLooksUsable") "OK"
    return [pscustomobject]@{
        Operation      = "Validate"
        Root           = $root
        InfCount       = $infFiles.Count
        MismatchCount  = $mismatches.Count
        Mismatches     = @($mismatches)
        MachineStatus  = $machineStatus
        MachineManifestPresent = $manifestPresent
        ChecksumResult = $checksumResult
        Message        = T "FinalValidateSummary" $infFiles.Count, $checksumResult.Checked
    }
}

function Resolve-InfValue {
    param(
        [string]$Value,
        [hashtable]$Strings
    )

    if ($null -eq $Value) {
        return ""
    }

    $clean = $Value.Trim().Trim('"')
    if ($clean -match '^%(?<name>[^%]+)%$') {
        $key = $Matches.name
        if ($Strings.ContainsKey($key)) {
            return [string]$Strings[$key]
        }
    }

    return $clean
}

function Get-DriverInfMetadata {
    param(
        [Parameter(Mandatory = $true)]
        [IO.FileInfo]$InfFile,

        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$DriversDir
    )

    $version = @{}
    $strings = @{}
    $section = ""

    try {
        $content = Get-Content -LiteralPath $InfFile.FullName -Raw -ErrorAction Stop
        foreach ($rawLine in ($content -split "\r?\n")) {
            $line = ($rawLine -replace ';.*$', '').Trim()
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            if ($line -match '^\[(?<section>[^\]]+)\]$') {
                $section = $Matches.section.Trim()
                continue
            }

            if ($line -notmatch '^(?<key>[^=]+)=(?<value>.*)$') {
                continue
            }

            $key = $Matches.key.Trim()
            $value = $Matches.value.Trim().Trim('"')
            if ($section -ieq "Version") {
                $version[$key] = $value
            }
            elseif ($section -like "Strings*") {
                $strings[$key] = $value
            }
        }

        $provider = Resolve-InfValue -Value ([string]$version.Provider) -Strings $strings
        $class = Resolve-InfValue -Value ([string]$version.Class) -Strings $strings
        $driverVer = Resolve-InfValue -Value ([string]$version.DriverVer) -Strings $strings

        return [pscustomobject]@{
            RelativePath = Get-RelativePath -BasePath $Root -Path $InfFile.FullName
            PackagePath  = Get-RelativePath -BasePath $DriversDir -Path $InfFile.DirectoryName
            InfName      = $InfFile.Name
            Provider     = $provider
            Class        = $class
            DriverVer    = $driverVer
            CanRead      = $true
            Error        = ""
        }
    }
    catch {
        return [pscustomobject]@{
            RelativePath = Get-RelativePath -BasePath $Root -Path $InfFile.FullName
            PackagePath  = Get-RelativePath -BasePath $DriversDir -Path $InfFile.DirectoryName
            InfName      = $InfFile.Name
            Provider     = ""
            Class        = ""
            DriverVer    = ""
            CanRead      = $false
            Error        = $_.Exception.Message
        }
    }
}

function Test-DriverBackupFileReadability {
    param(
        [string]$Root,
        [string]$DriversDir
    )

    $files = @(Get-DriverBackupFiles -DriversDir $DriversDir)
    $checked = 0
    $failures = New-Object System.Collections.Generic.List[object]

    foreach ($file in $files) {
        Test-DriverVaultCancel
        $checked++
        if (($checked % 50) -eq 0 -or $checked -eq $files.Count) {
            Set-DriverVaultProgress (T "ProgressReadFiles" $checked, $files.Count) $checked ([Math]::Max(1, $files.Count))
        }

        $stream = $null
        try {
            $stream = [IO.File]::Open($file.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
            if ($stream.Length -gt 0) {
                [void]$stream.ReadByte()
            }
        }
        catch {
            $relativePath = Get-RelativePath -BasePath $Root -Path $file.FullName
            $failure = [pscustomobject]@{
                RelativePath = $relativePath
                Error        = $_.Exception.Message
            }
            [void]$failures.Add($failure)
            Write-DriverVaultLog (T "DryRunFileUnreadable" $relativePath) "WARN"
        }
        finally {
            if ($stream) {
                $stream.Dispose()
            }
        }
    }

    if ($failures.Count -eq 0) {
        Write-DriverVaultLog (T "DryRunFileReadableOk" $checked) "OK"
    }

    return [pscustomobject]@{
        Checked  = $checked
        Failures = @($failures.ToArray())
        IsValid  = ($failures.Count -eq 0)
    }
}

function Invoke-DriverRestoreDryRun {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw (T "RestorePathRequired")
    }

    $root = [IO.Path]::GetFullPath($Path)
    $driversDir = Join-Path $root "Drivers"
    if (-not (Test-Path -LiteralPath $root)) {
        throw (T "ErrorBackupPathMissing" $root)
    }

    $logsDir = Join-Path $root "Logs"
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    $script:LogFile = Join-Path $logsDir ("dry-run_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

    Write-DriverVaultLog (T "DryRunStart")
    $precheck = Test-DriverBackup -Path $root

    $readability = Test-DriverBackupFileReadability -Root $root -DriversDir $driversDir
    if (-not $readability.IsValid) {
        throw (T "DryRunReadFailed" $readability.Failures.Count)
    }

    $infFiles = @(Get-ChildItem -LiteralPath $driversDir -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName)
    $candidates = @(foreach ($infFile in $infFiles) {
        Get-DriverInfMetadata -InfFile $infFile -Root $root -DriversDir $driversDir
    })

    $previewLimit = 25
    foreach ($candidate in ($candidates | Select-Object -First $previewLimit)) {
        $parts = @($candidate.InfName)
        if ($candidate.Provider) { $parts += $candidate.Provider }
        if ($candidate.Class) { $parts += $candidate.Class }
        if ($candidate.DriverVer) { $parts += $candidate.DriverVer }
        Write-DriverVaultLog (T "DryRunCandidate" ($parts -join " | "))
    }
    if ($candidates.Count -gt $previewLimit) {
        Write-DriverVaultLog (T "DryRunMoreCandidates" $previewLimit, $candidates.Count)
    }

    $machineStatusText = switch ($precheck.MachineStatus) {
        "Same" { T "DryRunMachineSame" }
        "Mismatch" { T "DryRunMachineMismatch" }
        default { T "DryRunMachineUnknown" }
    }

    $reportPath = Join-Path $logsDir ("dry-run_report_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    $reportLines = New-Object System.Collections.Generic.List[string]
    [void]$reportLines.Add((T "DryRunReportTitle"))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportCreatedAt"), (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportBackupRoot"), $root))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportInfPackages"), $candidates.Count))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportReadableFiles"), $readability.Checked))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportChecksumChecked"), $precheck.ChecksumResult.Checked))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportMachineStatus"), $machineStatusText))
    [void]$reportLines.Add(("{0}: {1}" -f (T "DryRunReportMachineMismatches"), $precheck.MismatchCount))
    foreach ($mismatch in @($precheck.Mismatches)) {
        [void]$reportLines.Add(("  - {0}" -f $mismatch))
    }
    [void]$reportLines.Add("")
    [void]$reportLines.Add(("{0}:" -f (T "DryRunReportCandidates")))
    foreach ($candidate in $candidates) {
        [void]$reportLines.Add(("- {0}" -f $candidate.RelativePath))
        if ($candidate.Provider) { [void]$reportLines.Add(("  {0}: {1}" -f (T "DryRunReportProvider"), $candidate.Provider)) }
        if ($candidate.Class) { [void]$reportLines.Add(("  {0}: {1}" -f (T "DryRunReportClass"), $candidate.Class)) }
        if ($candidate.DriverVer) { [void]$reportLines.Add(("  DriverVer: {0}" -f $candidate.DriverVer)) }
        if (-not $candidate.CanRead) { [void]$reportLines.Add(("  {0}: {1}" -f (T "DryRunReportReadError"), $candidate.Error)) }
    }
    Set-Content -LiteralPath $reportPath -Encoding UTF8 -Value $reportLines

    Write-DriverVaultLog (T "DryRunReportCreated" $reportPath) "OK"
    Write-DriverVaultLog (T "DryRunCompleted") "OK"
    return [pscustomobject]@{
        Operation        = "DryRun"
        Root             = $root
        InfCount         = $candidates.Count
        FileCount        = $readability.Checked
        ReportPath       = $reportPath
        CandidateDrivers = @($candidates)
        Message          = T "FinalDryRunSummary" $candidates.Count, $reportPath
    }
}

function Import-DriverBackup {
    param([string]$Path)

    if (-not (Test-IsAdministrator)) {
        throw (T "RestoreRequiresAdmin")
    }

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw (T "RestorePathRequired")
    }

    $root = [IO.Path]::GetFullPath($Path)
    $driversDir = Join-Path $root "Drivers"
    if (-not (Test-Path -LiteralPath $root)) {
        throw (T "ErrorBackupPathMissing" $root)
    }

    $logsDir = Join-Path $root "Logs"
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    $script:LogFile = Join-Path $logsDir ("restore_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

    $precheck = Test-DriverBackup -Path $root -StopOnMachineMismatch
    Write-DriverVaultLog (T "SimpleCheckOk") "OK"

    Write-DriverVaultLog (T "InstallDrivers")
    Invoke-LoggedCommand -FilePath (Get-SystemToolPath "pnputil.exe") -ArgumentList @(
        "/add-driver",
        (Join-Path $driversDir "*.inf"),
        "/subdirs",
        "/install"
    ) -ProgressKind "Install" -FailureContext "RestoreInstall" -ThrowOnError | Out-Null

    Write-DriverVaultLog (T "RestoreCompleted") "OK"
    return [pscustomobject]@{
        Operation = "Restore"
        Root      = $root
        InfCount  = $precheck.InfCount
        Message   = T "FinalRestoreSummary" $precheck.InfCount
    }
}

function Inspect-DriverBackup {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw (T "InspectPathRequired")
    }

    $root = [IO.Path]::GetFullPath($Path)
    $manifestPath = Join-Path $root "manifest.json"
    $driversDir = Join-Path $root "Drivers"
    $infFiles = @(Get-ChildItem -LiteralPath $driversDir -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue)

    Write-DriverVaultLog (T "BackupRoot" $root)
    Write-DriverVaultLog (T "InfFiles" $infFiles.Count)

    if (Test-Path -LiteralPath $manifestPath) {
        $manifest = Read-DriverVaultJsonFile -Path $manifestPath
        Write-DriverVaultLog (T "Created" $manifest.CreatedAt)
        Write-DriverVaultLog (T "Machine" $manifest.Machine.Manufacturer, $manifest.Machine.Model)
        Write-DriverVaultLog (T "OsLine" $manifest.Machine.OSName, $manifest.Machine.OSVersion)
        $mismatches = @(Get-BackupMachineMismatches -Root $root)
        if ($mismatches.Count -eq 0) {
            Write-DriverVaultLog (T "MachineLooksSame") "OK"
        }
        else {
            foreach ($mismatch in $mismatches) {
                Write-DriverVaultLog (T "MachineMismatch" $mismatch) "WARN"
            }
        }
    }
    else {
        Write-DriverVaultLog (T "ManifestMissingShort") "WARN"
    }

    $checksum = Test-DriverChecksumFile -Root $root
    return [pscustomobject]@{
        Operation     = "Inspect"
        Root          = $root
        InfCount      = $infFiles.Count
        ChecksumCount = $checksum.Checked
        Message       = T "FinalValidateSummary" $infFiles.Count, $checksum.Checked
    }
}

function Restart-DriverVaultElevated {
    param(
        [string]$StartMode,
        [string]$StartBackupPath,
        [string]$StartBackupScope = "Recommended"
    )

    if (-not $PSCommandPath) {
        throw (T "ScriptPathUnknown")
    }

    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", ('"{0}"' -f $PSCommandPath),
        "-Mode", $StartMode
    )

    if (-not [string]::IsNullOrWhiteSpace($StartBackupPath)) {
        $arguments += @("-BackupPath", ('"{0}"' -f $StartBackupPath))
    }

    if ($CreateZip) {
        $arguments += "-CreateZip"
    }
    if (-not [string]::IsNullOrWhiteSpace($StartBackupScope)) {
        $arguments += @("-BackupScope", $StartBackupScope)
    }
    $arguments += @("-Language", $script:UiLanguage)

    Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs
}

function Show-DriverVaultGui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $script:GuiMode = $true

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $colors = @{
        Window        = [System.Drawing.Color]::FromArgb(12, 17, 25)
        HeaderTop     = [System.Drawing.Color]::FromArgb(24, 34, 49)
        HeaderBottom  = [System.Drawing.Color]::FromArgb(13, 18, 27)
        Card          = [System.Drawing.Color]::FromArgb(21, 29, 41)
        CardAlt       = [System.Drawing.Color]::FromArgb(25, 35, 50)
        Border        = [System.Drawing.Color]::FromArgb(48, 61, 82)
        BorderSoft    = [System.Drawing.Color]::FromArgb(36, 48, 66)
        Text          = [System.Drawing.Color]::FromArgb(244, 248, 252)
        Muted         = [System.Drawing.Color]::FromArgb(155, 170, 190)
        Accent        = [System.Drawing.Color]::FromArgb(64, 156, 255)
        AccentDark    = [System.Drawing.Color]::FromArgb(37, 108, 196)
        Success       = [System.Drawing.Color]::FromArgb(50, 213, 131)
        Warning       = [System.Drawing.Color]::FromArgb(250, 190, 88)
        Danger        = [System.Drawing.Color]::FromArgb(244, 104, 104)
        LogBack       = [System.Drawing.Color]::FromArgb(7, 11, 18)
    }
    $fontUi = "Segoe UI"
    $fontUiStrong = "Segoe UI Semibold"
    if (-not ([System.Drawing.FontFamily]::Families | Where-Object { $_.Name -eq $fontUiStrong } | Select-Object -First 1)) {
        $fontUiStrong = "Segoe UI"
    }

    function New-DvPanel {
        param(
            [int]$X,
            [int]$Y,
            [int]$Width,
            [int]$Height,
            [System.Drawing.Color]$BackColor = $colors.Card
        )

        $panel = New-Object System.Windows.Forms.Panel
        $panel.Location = New-Object System.Drawing.Point($X, $Y)
        $panel.Size = New-Object System.Drawing.Size($Width, $Height)
        $panel.BackColor = $BackColor
        $panel.Padding = New-Object System.Windows.Forms.Padding(16)
        $panel.Add_Paint({
            param($sender, $event)
            $rect = $sender.ClientRectangle
            $rect.Width -= 1
            $rect.Height -= 1
            $pen = New-Object System.Drawing.Pen($colors.BorderSoft)
            $event.Graphics.DrawRectangle($pen, $rect)
            $pen.Dispose()
        })
        return $panel
    }

    function New-DvLabel {
        param(
            [string]$Text,
            [int]$X,
            [int]$Y,
            [float]$Size = 10,
            [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular,
            [System.Drawing.Color]$Color = $colors.Text
        )

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $Text
        $label.AutoSize = $true
        $label.Location = New-Object System.Drawing.Point($X, $Y)
        $fontName = if ($Style -eq [System.Drawing.FontStyle]::Bold) { $fontUiStrong } else { $fontUi }
        $fontStyle = if ($fontName -eq $fontUiStrong) { [System.Drawing.FontStyle]::Regular } else { $Style }
        $label.Font = New-Object System.Drawing.Font($fontName, $Size, $fontStyle, [System.Drawing.GraphicsUnit]::Point)
        $label.ForeColor = $Color
        $label.BackColor = [System.Drawing.Color]::Transparent
        $label.UseCompatibleTextRendering = $false
        return $label
    }

    function Set-DvButtonStyle {
        param(
            [System.Windows.Forms.Button]$Button,
            [System.Drawing.Color]$BackColor,
            [System.Drawing.Color]$ForeColor = $colors.Text
        )

        $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $Button.FlatAppearance.BorderSize = 1
        $Button.FlatAppearance.BorderColor = $colors.Border
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(
            [Math]::Min(255, $BackColor.R + 12),
            [Math]::Min(255, $BackColor.G + 12),
            [Math]::Min(255, $BackColor.B + 12)
        )
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(
            [Math]::Max(0, $BackColor.R - 16),
            [Math]::Max(0, $BackColor.G - 16),
            [Math]::Max(0, $BackColor.B - 16)
        )
        $Button.BackColor = $BackColor
        $Button.ForeColor = $ForeColor
        $Button.Font = New-Object System.Drawing.Font($fontUiStrong, 9.5, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
        $Button.Cursor = [System.Windows.Forms.Cursors]::Hand
        $Button.UseVisualStyleBackColor = $false
        $Button.UseCompatibleTextRendering = $false
    }

    function New-DvButton {
        param(
            [string]$Text,
            [int]$X,
            [int]$Y,
            [int]$Width,
            [int]$Height,
            [System.Drawing.Color]$BackColor = $colors.CardAlt,
            [System.Drawing.Color]$ForeColor = $colors.Text
        )

        $button = New-Object System.Windows.Forms.Button
        $button.Text = $Text
        $button.Location = New-Object System.Drawing.Point($X, $Y)
        $button.Size = New-Object System.Drawing.Size($Width, $Height)
        Set-DvButtonStyle -Button $button -BackColor $BackColor -ForeColor $ForeColor
        return $button
    }

    function New-DvStatusCard {
        param(
            [string]$Title,
            [string]$Value,
            [int]$X,
            [int]$Y,
            [int]$Width,
            [System.Drawing.Color]$ValueColor = $colors.Text
        )

        $panel = New-Object System.Windows.Forms.Panel
        $panel.Location = New-Object System.Drawing.Point($X, $Y)
        $panel.Size = New-Object System.Drawing.Size($Width, 58)
        $panel.BackColor = [System.Drawing.Color]::FromArgb(18, 26, 38)
        $panel.Add_Paint({
            param($sender, $event)
            $rect = $sender.ClientRectangle
            $rect.Width -= 1
            $rect.Height -= 1
            $pen = New-Object System.Drawing.Pen($colors.BorderSoft)
            $event.Graphics.DrawRectangle($pen, $rect)
            $pen.Dispose()
        })

        $titleLabel = New-DvLabel -Text $Title -X 10 -Y 8 -Size 8 -Color $colors.Muted
        $titleLabel.AutoSize = $false
        $titleLabel.AutoEllipsis = $true
        $titleLabel.Size = New-Object System.Drawing.Size(($Width - 20), 16)
        $panel.Controls.Add($titleLabel)

        $valueLabel = New-DvLabel -Text $Value -X 10 -Y 28 -Size 10 -Style ([System.Drawing.FontStyle]::Bold) -Color $ValueColor
        $valueLabel.AutoSize = $false
        $valueLabel.AutoEllipsis = $true
        $valueLabel.Size = New-Object System.Drawing.Size(($Width - 20), 22)
        $panel.Controls.Add($valueLabel)

        return [pscustomobject]@{
            Panel      = $panel
            ValueLabel = $valueLabel
        }
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = T "Title"
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
    $form.ClientSize = New-Object System.Drawing.Size(940, 640)
    $form.StartPosition = "CenterScreen"
    $form.MinimumSize = New-Object System.Drawing.Size(900, 620)
    $form.BackColor = $colors.Window
    $form.Font = New-Object System.Drawing.Font($fontUi, 9.5, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
    $form.ForeColor = $colors.Text
    $iconPath = Get-DriverVaultAssetPath -Name "DriverVault.ico"
    if (Test-Path -LiteralPath $iconPath) {
        try {
            $windowIcon = New-Object System.Drawing.Icon($iconPath)
            $form.Icon = $windowIcon
            $form.Add_FormClosed({
                if ($windowIcon) {
                    $windowIcon.Dispose()
                }
            })
        }
        catch {
            Write-DriverVaultLog $_.Exception.Message "WARN" -Detail
        }
    }

    $headerPanel = New-Object System.Windows.Forms.Panel
    $headerPanel.Dock = [System.Windows.Forms.DockStyle]::Top
    $headerPanel.Height = 102
    $headerPanel.Add_Paint({
        param($sender, $event)
        $rect = $sender.ClientRectangle
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $colors.HeaderTop, $colors.HeaderBottom, 90)
        $event.Graphics.FillRectangle($brush, $rect)
        $brush.Dispose()
        $pen = New-Object System.Drawing.Pen($colors.Border)
        $event.Graphics.DrawLine($pen, 0, $rect.Height - 1, $rect.Width, $rect.Height - 1)
        $pen.Dispose()
    })
    $form.Controls.Add($headerPanel)

    $title = New-DvLabel -Text "DriverVault" -X 26 -Y 14 -Size 22 -Style ([System.Drawing.FontStyle]::Bold)
    $headerPanel.Controls.Add($title)

    $subtitle = New-DvLabel -Text (T "HeaderSubtitle") -X 28 -Y 48 -Size 9.5 -Color $colors.Muted
    $subtitle.AutoSize = $false
    $subtitle.AutoEllipsis = $true
    $subtitle.Size = New-Object System.Drawing.Size(480, 20)
    $headerPanel.Controls.Add($subtitle)

    $adminLabel = New-DvLabel -Text "" -X 28 -Y 76 -Size 9
    $adminLabel.AutoSize = $false
    $adminLabel.AutoEllipsis = $true
    $adminLabel.Size = New-Object System.Drawing.Size(480, 20)
    if (Test-IsAdministrator) {
        $adminLabel.Text = T "AdminYes"
        $adminLabel.ForeColor = $colors.Success
    }
    else {
        $adminLabel.Text = T "AdminNo"
        $adminLabel.ForeColor = $colors.Warning
    }
    $headerPanel.Controls.Add($adminLabel)

    $adminCard = New-DvStatusCard -Title (T "StatusAdmin") -Value $(if (Test-IsAdministrator) { "OK" } else { "!" }) -X 570 -Y 20 -Width 92 -ValueColor $(if (Test-IsAdministrator) { $colors.Success } else { $colors.Warning })
    $script:GuiAdminValueLabel = $adminCard.ValueLabel
    $headerPanel.Controls.Add($adminCard.Panel)

    $infCard = New-DvStatusCard -Title (T "StatusInf") -Value "-" -X 674 -Y 20 -Width 92
    $script:GuiInfValueLabel = $infCard.ValueLabel
    $headerPanel.Controls.Add($infCard.Panel)

    $lastCard = New-DvStatusCard -Title (T "StatusLast") -Value (Get-LatestBackupDisplayName) -X 778 -Y 20 -Width 136
    $script:GuiLastValueLabel = $lastCard.ValueLabel
    $headerPanel.Controls.Add($lastCard.Panel)

    $pathPanel = New-DvPanel -X 24 -Y 118 -Width 892 -Height 110
    $pathPanel.Anchor = "Top,Left,Right"
    $form.Controls.Add($pathPanel)

    $pathLabel = New-DvLabel -Text (T "BackupFolder") -X 20 -Y 16 -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
    $pathPanel.Controls.Add($pathLabel)

    $pathText = New-Object System.Windows.Forms.TextBox
    $pathText.Location = New-Object System.Drawing.Point(20, 46)
    $pathText.Size = New-Object System.Drawing.Size(700, 30)
    $pathText.Text = $(if ($BackupPath) { $BackupPath } else { New-DefaultBackupPath })
    $pathText.Font = New-Object System.Drawing.Font($fontUi, 10, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
    $pathText.BackColor = [System.Drawing.Color]::FromArgb(10, 15, 24)
    $pathText.ForeColor = $colors.Text
    $pathText.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $pathText.Anchor = "Top,Left"
    $pathPanel.Controls.Add($pathText)

    $browseButton = New-DvButton -Text (T "BrowseButton") -X 740 -Y 43 -Width 132 -Height 34 -BackColor $colors.CardAlt
    $browseButton.Anchor = "Top,Left"
    $browseButton.Add_Click({
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = T "BrowseDescription"
        if (Test-Path -LiteralPath $pathText.Text) {
            $dialog.SelectedPath = $pathText.Text
        }
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $pathText.Text = $dialog.SelectedPath
        }
    })
    $pathPanel.Controls.Add($browseButton)

    $zipCheck = New-Object System.Windows.Forms.CheckBox
    $zipCheck.Text = T "ZipCheck"
    $zipCheck.AutoSize = $false
    $zipCheck.AutoEllipsis = $true
    $zipCheck.Location = New-Object System.Drawing.Point(20, 82)
    $zipCheck.Size = New-Object System.Drawing.Size(430, 24)
    $zipCheck.Checked = [bool]$CreateZip
    $zipCheck.ForeColor = $colors.Muted
    $zipCheck.BackColor = [System.Drawing.Color]::Transparent
    $zipCheck.Font = New-Object System.Drawing.Font($fontUi, 9.5, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
    $zipCheck.UseCompatibleTextRendering = $false
    $pathPanel.Controls.Add($zipCheck)

    $scopeLabel = New-DvLabel -Text (T "BackupModeLabel") -X 520 -Y 82 -Size 9 -Color $colors.Muted
    $scopeLabel.AutoSize = $false
    $scopeLabel.AutoEllipsis = $true
    $scopeLabel.Size = New-Object System.Drawing.Size(64, 22)
    $pathPanel.Controls.Add($scopeLabel)

    $scopeCombo = New-Object System.Windows.Forms.ComboBox
    $scopeCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    [void]$scopeCombo.Items.Add((T "BackupModeRecommended"))
    [void]$scopeCombo.Items.Add((T "BackupModeFull"))
    $scopeCombo.SelectedIndex = if ($BackupScope -eq "Full") { 1 } else { 0 }
    $scopeCombo.Location = New-Object System.Drawing.Point(570, 78)
    $scopeCombo.Size = New-Object System.Drawing.Size(150, 28)
    $scopeCombo.Font = New-Object System.Drawing.Font($fontUi, 9, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
    $scopeCombo.BackColor = [System.Drawing.Color]::FromArgb(10, 15, 24)
    $scopeCombo.ForeColor = $colors.Text
    $scopeCombo.Anchor = "Top,Left"
    $pathPanel.Controls.Add($scopeCombo)

    $actionsPanel = New-DvPanel -X 24 -Y 244 -Width 892 -Height 112 -BackColor $colors.CardAlt
    $actionsPanel.Anchor = "Top,Left,Right"
    $form.Controls.Add($actionsPanel)

    $actionsTitle = New-DvLabel -Text "Actions" -X 20 -Y 14 -Size 10 -Style ([System.Drawing.FontStyle]::Bold) -Color $colors.Muted
    if ($script:UiLanguage -eq "ru") { $actionsTitle.Text = "Действия" }
    $actionsPanel.Controls.Add($actionsTitle)

    $backupButton = New-DvButton -Text (T "BackupButton") -X 20 -Y 48 -Width 190 -Height 42 -BackColor $colors.Accent
    $actionsPanel.Controls.Add($backupButton)

    $restoreButton = New-DvButton -Text (T "RestoreButton") -X 224 -Y 48 -Width 150 -Height 42 -BackColor $colors.AccentDark
    $actionsPanel.Controls.Add($restoreButton)

    $validateButton = New-DvButton -Text (T "CheckRestoreButton") -X 388 -Y 48 -Width 142 -Height 42
    $actionsPanel.Controls.Add($validateButton)

    $dryRunButton = New-DvButton -Text (T "DryRunButton") -X 544 -Y 48 -Width 122 -Height 42
    $actionsPanel.Controls.Add($dryRunButton)

    $inspectButton = New-DvButton -Text (T "InspectButton") -X 680 -Y 48 -Width 122 -Height 42
    $actionsPanel.Controls.Add($inspectButton)

    $elevateButton = New-DvButton -Text (T "RestartAsAdmin") -X 816 -Y 48 -Width 110 -Height 42 -BackColor $colors.Warning -ForeColor ([System.Drawing.Color]::FromArgb(24, 24, 24))
    $elevateButton.Enabled = -not (Test-IsAdministrator)
    $elevateButton.Add_Click({
        try {
            Restart-DriverVaultElevated -StartMode "Gui" -StartBackupPath $pathText.Text
            $form.Close()
        }
        catch {
            [void](Write-FriendlyCaughtError $_)
        }
    })
    $actionsPanel.Controls.Add($elevateButton)

    $openButton = New-DvButton -Text (T "OpenFolder") -X 806 -Y 48 -Width 66 -Height 42
    $openButton.Anchor = "Top,Left"
    $openButton.Add_Click({
        if (Test-Path -LiteralPath $pathText.Text) {
            Start-Process explorer.exe -ArgumentList ('"{0}"' -f $pathText.Text)
        }
    })
    $actionsPanel.Controls.Add($openButton)

    $cancelButton = New-DvButton -Text (T "CancelButton") -X 806 -Y 14 -Width 66 -Height 26 -BackColor $colors.Danger
    $cancelButton.Enabled = $false
    $cancelButton.Add_Click({
        Request-DriverVaultCancel
    })
    $actionsPanel.Controls.Add($cancelButton)

    $logPanel = New-DvPanel -X 24 -Y 374 -Width 892 -Height 194 -BackColor $colors.Card
    $logPanel.Anchor = "Top,Bottom,Left,Right"
    $form.Controls.Add($logPanel)

    $logTitle = New-DvLabel -Text (T "LogTitle") -X 18 -Y 12 -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
    $logPanel.Controls.Add($logTitle)

    $script:GuiSummaryLabel = New-Object System.Windows.Forms.Label
    $script:GuiSummaryLabel.Text = T "DetailLogHint"
    $script:GuiSummaryLabel.Location = New-Object System.Drawing.Point(150, 12)
    $script:GuiSummaryLabel.Size = New-Object System.Drawing.Size(724, 20)
    $script:GuiSummaryLabel.AutoSize = $false
    $script:GuiSummaryLabel.AutoEllipsis = $true
    $script:GuiSummaryLabel.Font = New-Object System.Drawing.Font($fontUi, 9, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
    $script:GuiSummaryLabel.ForeColor = $colors.Muted
    $script:GuiSummaryLabel.BackColor = [System.Drawing.Color]::Transparent
    $logPanel.Controls.Add($script:GuiSummaryLabel)

    $script:GuiLogBox = New-Object System.Windows.Forms.TextBox
    $script:GuiLogBox.Location = New-Object System.Drawing.Point(18, 40)
    $script:GuiLogBox.Size = New-Object System.Drawing.Size(856, 134)
    $script:GuiLogBox.Anchor = "Top,Bottom,Left,Right"
    $script:GuiLogBox.Multiline = $true
    $script:GuiLogBox.ScrollBars = "Vertical"
    $script:GuiLogBox.ReadOnly = $true
    $script:GuiLogBox.Font = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
    $script:GuiLogBox.BackColor = $colors.LogBack
    $script:GuiLogBox.ForeColor = [System.Drawing.Color]::FromArgb(217, 230, 245)
    $script:GuiLogBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $logPanel.Controls.Add($script:GuiLogBox)

    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Location = New-Object System.Drawing.Point(24, 586)
    $progress.Size = New-Object System.Drawing.Size(892, 8)
    $progress.Anchor = "Bottom,Left,Right"
    $progress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    $progress.MarqueeAnimationSpeed = 25
    $progress.Visible = $false
    $form.Controls.Add($progress)
    $script:GuiProgressBar = $progress

    $statusLabel = New-DvLabel -Text (T "Ready") -X 24 -Y 606 -Size 9 -Color $colors.Muted
    $statusLabel.AutoSize = $false
    $statusLabel.AutoEllipsis = $true
    $statusLabel.Size = New-Object System.Drawing.Size(892, 20)
    $statusLabel.Anchor = "Bottom,Left"
    $form.Controls.Add($statusLabel)
    $script:GuiStatusLabel = $statusLabel

    function Update-DvResponsiveLayout {
        $outer = 24
        $panelWidth = [Math]::Max(760, $form.ClientSize.Width - ($outer * 2))

        $pathPanel.Location = New-Object System.Drawing.Point($outer, 118)
        $pathPanel.Size = New-Object System.Drawing.Size($panelWidth, 110)
        $actionsPanel.Location = New-Object System.Drawing.Point($outer, 244)
        $actionsPanel.Size = New-Object System.Drawing.Size($panelWidth, 112)
        $logPanel.Location = New-Object System.Drawing.Point($outer, 374)
        $logPanel.Size = New-Object System.Drawing.Size($panelWidth, [Math]::Max(160, $form.ClientSize.Height - 446))

        $progress.Location = New-Object System.Drawing.Point($outer, ($form.ClientSize.Height - 54))
        $progress.Size = New-Object System.Drawing.Size($panelWidth, 8)
        $statusLabel.Location = New-Object System.Drawing.Point($outer, ($form.ClientSize.Height - 34))
        $statusLabel.Size = New-Object System.Drawing.Size($panelWidth, 20)

        $headerRight = [Math]::Max(760, $headerPanel.ClientSize.Width)
        $gap = 10
        $lastWidth = 170
        $smallWidth = 92
        $cardY = 18
        $lastX = $headerRight - $outer - $lastWidth
        $infX = $lastX - $gap - $smallWidth
        $adminX = $infX - $gap - $smallWidth
        $adminCard.Panel.Location = New-Object System.Drawing.Point($adminX, $cardY)
        $infCard.Panel.Location = New-Object System.Drawing.Point($infX, $cardY)
        $lastCard.Panel.Location = New-Object System.Drawing.Point($lastX, $cardY)
        $lastCard.Panel.Size = New-Object System.Drawing.Size($lastWidth, 58)
        $lastCard.ValueLabel.Size = New-Object System.Drawing.Size(($lastWidth - 20), 22)
        $subtitle.Size = New-Object System.Drawing.Size([Math]::Max(260, $adminX - 56), 20)
        $adminLabel.Size = New-Object System.Drawing.Size([Math]::Max(260, $adminX - 56), 20)

        $innerMargin = 16
        $browseWidth = 96
        $browseX = $pathPanel.ClientSize.Width - $innerMargin - $browseWidth
        $pathLabel.Location = New-Object System.Drawing.Point($innerMargin, 14)
        $pathText.Location = New-Object System.Drawing.Point($innerMargin, 44)
        $pathText.Size = New-Object System.Drawing.Size([Math]::Max(260, $browseX - $innerMargin - 12), 28)
        $browseButton.Location = New-Object System.Drawing.Point($browseX, 42)
        $browseButton.Size = New-Object System.Drawing.Size($browseWidth, 32)

        $scopeComboWidth = 160
        $scopeLabelWidth = 64
        $scopeComboX = $pathPanel.ClientSize.Width - $innerMargin - $scopeComboWidth
        $scopeLabelX = $scopeComboX - $scopeLabelWidth - 8
        $zipCheck.Location = New-Object System.Drawing.Point($innerMargin, 80)
        $zipCheck.Size = New-Object System.Drawing.Size([Math]::Max(220, $scopeLabelX - $innerMargin - 16), 24)
        $scopeLabel.Location = New-Object System.Drawing.Point($scopeLabelX, 82)
        $scopeLabel.Size = New-Object System.Drawing.Size($scopeLabelWidth, 22)
        $scopeCombo.Location = New-Object System.Drawing.Point($scopeComboX, 78)
        $scopeCombo.Size = New-Object System.Drawing.Size($scopeComboWidth, 28)

        $buttonY = 48
        $buttonHeight = 42
        $buttonGap = 10
        $buttonX = $innerMargin
        $actionButtons = @(
            [pscustomobject]@{ Control = $backupButton; Width = 112 },
            [pscustomobject]@{ Control = $restoreButton; Width = 118 },
            [pscustomobject]@{ Control = $validateButton; Width = 96 },
            [pscustomobject]@{ Control = $dryRunButton; Width = 106 },
            [pscustomobject]@{ Control = $inspectButton; Width = 96 },
            [pscustomobject]@{ Control = $elevateButton; Width = 82 },
            [pscustomobject]@{ Control = $openButton; Width = 82 },
            [pscustomobject]@{ Control = $cancelButton; Width = 78 }
        )
        foreach ($item in $actionButtons) {
            $item.Control.Location = New-Object System.Drawing.Point($buttonX, $buttonY)
            $item.Control.Size = New-Object System.Drawing.Size($item.Width, $buttonHeight)
            $buttonX += $item.Width + $buttonGap
        }

        $logTitle.Location = New-Object System.Drawing.Point(16, 12)
        $script:GuiSummaryLabel.Location = New-Object System.Drawing.Point(150, 12)
        $script:GuiSummaryLabel.Size = New-Object System.Drawing.Size([Math]::Max(260, $logPanel.ClientSize.Width - 170), 20)
        $script:GuiLogBox.Location = New-Object System.Drawing.Point(16, 40)
        $script:GuiLogBox.Size = New-Object System.Drawing.Size([Math]::Max(260, $logPanel.ClientSize.Width - 32), [Math]::Max(90, $logPanel.ClientSize.Height - 60))
    }

    $form.Add_Resize({
        Update-DvResponsiveLayout
    })

    $runAction = {
        param([scriptblock]$Action)

        $buttons = @($backupButton, $restoreButton, $validateButton, $dryRunButton, $inspectButton, $elevateButton, $openButton, $browseButton, $scopeCombo)
        $script:CancelRequested = $false
        foreach ($button in $buttons) { $button.Enabled = $false }
        $cancelButton.Enabled = $true
        $progress.Visible = $true
        $progress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $statusLabel.Text = if ($script:UiLanguage -eq "ru") { "Выполняется операция..." } else { "Operation in progress..." }
        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
        [System.Windows.Forms.Application]::DoEvents()
        $operationStatus = T "Ready"
        try {
            $result = & $Action
            Show-DriverVaultSummary $result
        }
        catch {
            $friendlyError = Write-FriendlyCaughtError $_
            $operationStatus = $friendlyError
            if ($script:GuiSummaryLabel) {
                $script:GuiSummaryLabel.Text = $friendlyError
                $script:GuiSummaryLabel.ForeColor = $colors.Danger
            }
        }
        finally {
            foreach ($button in $buttons) { $button.Enabled = $true }
            $elevateButton.Enabled = -not (Test-IsAdministrator)
            $cancelButton.Enabled = $false
            Reset-DriverVaultProgress
            $statusLabel.Text = $operationStatus
            $form.Cursor = [System.Windows.Forms.Cursors]::Default
            $script:CancelRequested = $false
        }
    }

    $backupButton.Add_Click({
        if (-not (Test-IsAdministrator)) {
            Restart-DriverVaultElevated -StartMode "Gui" -StartBackupPath $pathText.Text -StartBackupScope $(if ($scopeCombo.SelectedIndex -eq 1) { "Full" } else { "Recommended" })
            $form.Close()
            return
        }
        & $runAction {
            Export-DriverBackup -Path $pathText.Text -Zip:($zipCheck.Checked) -Scope $(if ($scopeCombo.SelectedIndex -eq 1) { "Full" } else { "Recommended" })
        }
    })

    $restoreButton.Add_Click({
        if (-not (Test-IsAdministrator)) {
            Restart-DriverVaultElevated -StartMode "Gui" -StartBackupPath $pathText.Text -StartBackupScope $(if ($scopeCombo.SelectedIndex -eq 1) { "Full" } else { "Recommended" })
            $form.Close()
            return
        }
        & $runAction {
            Import-DriverBackup -Path $pathText.Text
        }
    })

    $validateButton.Add_Click({
        & $runAction {
            Test-DriverBackup -Path $pathText.Text
        }
    })

    $dryRunButton.Add_Click({
        & $runAction {
            Invoke-DriverRestoreDryRun -Path $pathText.Text
        }
    })

    $inspectButton.Add_Click({
        & $runAction {
            Inspect-DriverBackup -Path $pathText.Text
        }
    })

    Update-DvResponsiveLayout
    Write-DriverVaultLog (T "Ready")
    [void]$form.ShowDialog()
}

try {
    switch ($Mode) {
        "Gui" {
            Show-DriverVaultGui
        }
        "Backup" {
            Export-DriverBackup -Path $BackupPath -Zip:$CreateZip -Scope $BackupScope | Out-Null
        }
        "Restore" {
            Import-DriverBackup -Path $BackupPath
        }
        "Inspect" {
            Inspect-DriverBackup -Path $BackupPath | Out-Null
        }
        "Validate" {
            Test-DriverBackup -Path $BackupPath | Out-Null
        }
        "DryRun" {
            Invoke-DriverRestoreDryRun -Path $BackupPath | Out-Null
        }
    }
}
catch {
    [void](Write-FriendlyCaughtError $_)
    if (-not $script:GuiMode -and -not $NoPause) {
        Write-Host ""
        Read-Host (T "PressEnter")
    }
    exit 1
}
