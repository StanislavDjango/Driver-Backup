$ErrorActionPreference = "Stop"

BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $script:DriverVaultScript = Join-Path $repoRoot "DriverVault.ps1"

    . $script:DriverVaultScript -Mode Validate -Language en -ImportOnly

    function Get-TestRootPath {
        param([string]$Name)

        return (Join-Path (Get-PSDrive TestDrive).Root $Name)
    }

    function New-TestDriverBackup {
        param(
            [string]$Name = ("backup_" + [guid]::NewGuid().ToString("N")),
            [switch]$SkipManifest,
            [switch]$SkipChecksums,
            [switch]$NoInf
        )

        $root = Get-TestRootPath -Name $Name
        $driversDir = Join-Path $root "Drivers\sample_amd64_123"
        New-Item -ItemType Directory -Path $driversDir -Force | Out-Null

        $infPath = Join-Path $driversDir "sample.inf"
        if (-not $NoInf) {
            @(
                "[Version]",
                'Signature="$Windows NT$"',
                "Class=System",
                "Provider=%ProviderName%",
                "DriverVer=01/01/2026,1.0.0.0",
                "",
                "[Strings]",
                'ProviderName="DriverVault Test"'
            ) | Set-Content -LiteralPath $infPath -Encoding ASCII
        }

        $driverFile = Join-Path $driversDir "sample.sys"
        "fake driver bytes" | Set-Content -LiteralPath $driverFile -Encoding ASCII

        if (-not $SkipManifest) {
            $manifest = [ordered]@{
                ToolName          = "DriverVault"
                ToolVersion       = "0.4.2"
                Language          = "en"
                CreatedAt         = (Get-Date).ToString("o")
                BackupRoot        = $root
                DriversFolder     = "Drivers"
                BackupScope       = "Recommended"
                ExportMethod      = "TestFixture"
                ExportedInfCount  = $(if ($NoInf) { 0 } else { 1 })
                ExportedFileCount = $(if ($NoInf) { 1 } else { 2 })
                ChecksumFile      = "checksums.json"
                ChecksumFileCount = 0
                Status            = "OK"
                Machine           = Get-MachineIdentity
            }
            Write-JsonFile -InputObject $manifest -Path (Join-Path $root "manifest.json")
        }

        if (-not $SkipChecksums) {
            New-DriverChecksumFile -Root $root -DriversDir (Join-Path $root "Drivers") | Out-Null
        }

        return [pscustomobject]@{
            Root       = $root
            DriversDir = Join-Path $root "Drivers"
            InfPath    = $infPath
            DriverFile = $driverFile
        }
    }

    function Assert-DriverVaultErrorCode {
        param(
            [scriptblock]$ScriptBlock,
            [string]$ExpectedCode
        )

        try {
            & $ScriptBlock
            throw "Expected DriverVault error code $ExpectedCode."
        }
        catch {
            Get-DriverVaultErrorCode -ErrorRecord $_ | Should -Be $ExpectedCode
        }
    }

    function Set-TestManifestMachineValue {
        param(
            [string]$Root,
            [string]$Name,
            [string]$Value
        )

        $manifestPath = Join-Path $Root "manifest.json"
        $manifest = Read-DriverVaultJsonFile -Path $manifestPath
        $manifest.Machine.$Name = $Value
        Write-JsonFile -InputObject $manifest -Path $manifestPath
    }
}

Describe "DriverVault core validation" {
    BeforeEach {
        $script:LogFile = $null
        $script:GuiMode = $true
        $script:CancelRequested = $false
    }

    It "validates a healthy backup folder with INF and SHA256 files" {
        $backup = New-TestDriverBackup

        $result = Test-DriverBackup -Path $backup.Root

        $result.Operation | Should -Be "Validate"
        $result.InfCount | Should -Be 1
        $result.ChecksumResult.IsValid | Should -BeTrue
        $result.ChecksumResult.Checked | Should -Be 2
        $result.MachineStatus | Should -Be "Same"
    }

    It "rejects a missing backup path before reading metadata" {
        $missingPath = Get-TestRootPath -Name "missing_backup"

        { Test-DriverBackup -Path $missingPath } | Should -Throw -ExpectedMessage "*does not exist*"
    }

    It "rejects a backup folder without INF files" {
        $backup = New-TestDriverBackup -NoInf -SkipChecksums

        { Test-DriverBackup -Path $backup.Root } | Should -Throw -ExpectedMessage "*No INF driver files*"
    }

    It "uses NO_INF code when a backup has no INF files" {
        $backup = New-TestDriverBackup -NoInf -SkipChecksums

        Assert-DriverVaultErrorCode -ExpectedCode "NO_INF" -ScriptBlock {
            Test-DriverBackup -Path $backup.Root
        }
    }

    It "rejects a backup when the Drivers folder is missing" {
        $backup = New-TestDriverBackup
        Remove-Item -LiteralPath $backup.DriversDir -Recurse -Force

        Assert-DriverVaultErrorCode -ExpectedCode "DRIVERS_FOLDER_MISSING" -ScriptBlock {
            Test-DriverBackup -Path $backup.Root
        }
    }

    It "rejects damaged manifest JSON" {
        $backup = New-TestDriverBackup -SkipManifest
        Set-Content -LiteralPath (Join-Path $backup.Root "manifest.json") -Encoding ASCII -Value "{ damaged json"

        { Test-DriverBackup -Path $backup.Root } | Should -Throw -ExpectedMessage "*manifest.json*"
    }

    It "uses METADATA_DAMAGED code for corrupted manifest JSON" {
        $backup = New-TestDriverBackup -SkipManifest
        Set-Content -LiteralPath (Join-Path $backup.Root "manifest.json") -Encoding ASCII -Value "{ damaged json"

        Assert-DriverVaultErrorCode -ExpectedCode "METADATA_DAMAGED" -ScriptBlock {
            Test-DriverBackup -Path $backup.Root
        }
    }

    It "detects missing driver files through SHA256 validation" {
        $backup = New-TestDriverBackup
        Remove-Item -LiteralPath $backup.DriverFile -Force

        $checksum = Test-DriverChecksumFile -Root $backup.Root

        $checksum.Present | Should -BeTrue
        $checksum.IsValid | Should -BeFalse
        $checksum.Missing | Should -Be 1
    }

    It "detects changed driver files through SHA256 validation" {
        $backup = New-TestDriverBackup
        "tampered driver bytes" | Set-Content -LiteralPath $backup.DriverFile -Encoding ASCII

        $checksum = Test-DriverChecksumFile -Root $backup.Root

        $checksum.Present | Should -BeTrue
        $checksum.IsValid | Should -BeFalse
        $checksum.Mismatch | Should -Be 1
    }

    It "uses CHECKSUM_DAMAGED code when validation sees changed files" {
        $backup = New-TestDriverBackup
        "tampered driver bytes" | Set-Content -LiteralPath $backup.DriverFile -Encoding ASCII

        Assert-DriverVaultErrorCode -ExpectedCode "CHECKSUM_DAMAGED" -ScriptBlock {
            Test-DriverBackup -Path $backup.Root
        }
    }

    It "uses METADATA_DAMAGED code for corrupted checksums JSON" {
        $backup = New-TestDriverBackup
        Set-Content -LiteralPath (Join-Path $backup.Root "checksums.json") -Encoding ASCII -Value "{ broken checksums"

        Assert-DriverVaultErrorCode -ExpectedCode "METADATA_DAMAGED" -ScriptBlock {
            Test-DriverBackup -Path $backup.Root
        }
    }
}

Describe "DriverVault inspect and dry-run" {
    BeforeEach {
        $script:LogFile = $null
        $script:GuiMode = $true
        $script:CancelRequested = $false
    }

    It "returns a detailed inspect summary and writes an inspect report" {
        $backup = New-TestDriverBackup

        $summary = Inspect-DriverBackup -Path $backup.Root

        $summary.Operation | Should -Be "Inspect"
        $summary.InfCount | Should -Be 1
        $summary.FileCount | Should -Be 2
        $summary.ChecksumStatusText | Should -Be "SHA256 OK"
        $summary.MachineStatus | Should -Be "Same"
        Test-Path -LiteralPath $summary.ReportPath | Should -BeTrue
        ($summary.DisplayLines -join "`n") | Should -Match "PC model"
    }

    It "checks restore candidates without installing drivers" {
        $backup = New-TestDriverBackup

        $result = Invoke-DriverRestoreDryRun -Path $backup.Root

        $result.Operation | Should -Be "DryRun"
        $result.InfCount | Should -Be 1
        $result.FileCount | Should -Be 2
        $result.CandidateDrivers[0].InfName | Should -Be "sample.inf"
        Test-Path -LiteralPath $result.ReportPath | Should -BeTrue
    }
}

Describe "DriverVault backup and restore guards" {
    BeforeEach {
        $script:LogFile = $null
        $script:GuiMode = $true
        $script:CancelRequested = $false
    }

    It "requires Administrator rights before backup export starts" {
        Mock Test-IsAdministrator { return $false }

        { Export-DriverBackup -Path (Get-TestRootPath -Name "new_backup") } | Should -Throw -ExpectedMessage "*administrator*"
    }

    It "requires Administrator rights before restore starts" {
        Mock Test-IsAdministrator { return $false }

        { Import-DriverBackup -Path (Get-TestRootPath -Name "restore_backup") } | Should -Throw -ExpectedMessage "*administrator*"
    }

    It "stops restore when manifest.json is missing" {
        $backup = New-TestDriverBackup -SkipManifest
        Mock Test-IsAdministrator { return $true }
        Mock Invoke-LoggedCommand { throw "Install should not run without manifest.json" }

        { Import-DriverBackup -Path $backup.Root } | Should -Throw -ExpectedMessage "*manifest.json*"
        Assert-MockCalled Invoke-LoggedCommand -Times 0 -Exactly
    }

    It "keeps a structured error code for missing restore metadata" {
        $backup = New-TestDriverBackup -SkipManifest
        Mock Test-IsAdministrator { return $true }

        Assert-DriverVaultErrorCode -ExpectedCode "MANIFEST_REQUIRED" -ScriptBlock {
            Import-DriverBackup -Path $backup.Root
        }
    }

    It "stops restore for a backup from another PC before installing drivers" {
        $backup = New-TestDriverBackup
        Set-TestManifestMachineValue -Root $backup.Root -Name "Model" -Value "Definitely Another PC Model"
        Mock Test-IsAdministrator { return $true }
        Mock Invoke-LoggedCommand { throw "Install should not run for a different PC" }

        Assert-DriverVaultErrorCode -ExpectedCode "WRONG_PC" -ScriptBlock {
            Import-DriverBackup -Path $backup.Root
        }
        Assert-MockCalled Invoke-LoggedCommand -Times 0 -Exactly
    }
}

Describe "DriverVault utility helpers" {
    BeforeEach {
        $script:LogFile = $null
        $script:GuiMode = $true
        $script:CancelRequested = $false
    }

    It "formats byte sizes for reports" {
        Format-DriverVaultByteSize -Bytes 0 | Should -Be "0 B"
        Format-DriverVaultByteSize -Bytes 1536 | Should -Match "^1[,.]5 KB$"
    }

    It "keeps structured error codes on DriverVault exceptions" {
        Assert-DriverVaultErrorCode -ExpectedCode "NO_INF" -ScriptBlock {
            throw (New-DriverVaultError -Code "NO_INF" -Message "No INF")
        }
    }

    It "rejects a file path when choosing a backup destination" {
        $filePath = Get-TestRootPath -Name "not_a_backup_folder.txt"
        Set-Content -LiteralPath $filePath -Encoding ASCII -Value "not a folder"

        Assert-DriverVaultErrorCode -ExpectedCode "PATH_MISSING" -ScriptBlock {
            Resolve-BackupDestinationPath -Path $filePath
        }
    }

    It "fails early when required free space is impossible" {
        $path = Get-TestRootPath -Name "space_check"
        New-Item -ItemType Directory -Path $path -Force | Out-Null

        { Test-RequiredFreeSpace -Path $path -RequiredBytes ([int64]::MaxValue) } | Should -Throw -ExpectedMessage "*free space*"
    }

    It "creates a sibling folder when an existing backup folder is selected for backup" {
        $parent = Get-TestRootPath -Name "backup_parent"
        $existing = Join-Path $parent "DriverVault_existing"
        New-Item -ItemType Directory -Path $existing -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $existing "manifest.json") -Encoding ASCII -Value "{}"

        $resolved = Resolve-BackupDestinationPath -Path $existing

        $resolved | Should -Not -Be $existing
        (Split-Path -Parent $resolved) | Should -Be $parent
        (Split-Path -Leaf $resolved) | Should -Match "^DriverVault_"
    }

    It "creates a child folder when a non-empty parent folder is selected for backup" {
        $parent = Get-TestRootPath -Name "non_empty_parent"
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $parent "note.txt") -Encoding ASCII -Value "keep"

        $resolved = Resolve-BackupDestinationPath -Path $parent

        $resolved | Should -Not -Be $parent
        (Split-Path -Parent $resolved) | Should -Be $parent
        (Split-Path -Leaf $resolved) | Should -Match "^DriverVault_"
    }

    It "finds DriverVault backups for the history window" {
        $backup = New-TestDriverBackup -Name "DriverVault_history_test"

        $history = @(Get-DriverVaultBackupHistory -SelectedPath $backup.Root)
        $item = @($history | Where-Object { $_.Root -eq ([IO.Path]::GetFullPath($backup.Root)) } | Select-Object -First 1)

        $item.Count | Should -Be 1
        $item[0].InfCount | Should -Be 1
        $item[0].ChecksumStatusText | Should -Be "SHA256 OK"
        $item[0].MachineStatus | Should -Be "Same"
    }
}
