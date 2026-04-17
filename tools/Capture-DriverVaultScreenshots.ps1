param(
    [string]$OutputDirectory = "",
    [int]$WaitSeconds = 12
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$scriptPath = Join-Path $root "DriverVault.ps1"

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $root "docs\assets\screenshots"
}

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "DriverVault.ps1 was not found: $scriptPath"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
Add-Type -AssemblyName System.Drawing

$nativeCode = @"
using System;
using System.Runtime.InteropServices;

public static class DriverVaultNativeCapture {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, uint nFlags);
}
"@

if (-not ("DriverVaultNativeCapture" -as [type])) {
    Add-Type -TypeDefinition $nativeCode
}

function Save-WindowScreenshot {
    param(
        [IntPtr]$Handle,
        [string]$Path
    )

    [DriverVaultNativeCapture]::SetForegroundWindow($Handle) | Out-Null
    Start-Sleep -Milliseconds 700

    $rect = New-Object DriverVaultNativeCapture+RECT
    if (-not [DriverVaultNativeCapture]::GetWindowRect($Handle, [ref]$rect)) {
        throw "Could not read window rectangle."
    }

    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    if ($width -le 0 -or $height -le 0) {
        throw "Window rectangle is invalid: ${width}x${height}."
    }

    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $hdc = $graphics.GetHdc()
        try {
            $printed = [DriverVaultNativeCapture]::PrintWindow($Handle, $hdc, 0)
        }
        finally {
            $graphics.ReleaseHdc($hdc)
        }

        if (-not $printed) {
            $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, (New-Object System.Drawing.Size($width, $height)))
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Get-DriverVaultWindowHandle {
    param([int]$ProcessId)

    $matches = New-Object System.Collections.Generic.List[object]
    $callback = [DriverVaultNativeCapture+EnumWindowsProc]{
        param([IntPtr]$handle, [IntPtr]$param)

        $windowProcessId = [uint32]0
        [void][DriverVaultNativeCapture]::GetWindowThreadProcessId($handle, [ref]$windowProcessId)
        if ($windowProcessId -ne [uint32]$ProcessId) {
            return $true
        }

        if (-not [DriverVaultNativeCapture]::IsWindowVisible($handle)) {
            return $true
        }

        $length = [DriverVaultNativeCapture]::GetWindowTextLength($handle)
        if ($length -le 0) {
            return $true
        }

        $builder = New-Object System.Text.StringBuilder($length + 1)
        [void][DriverVaultNativeCapture]::GetWindowText($handle, $builder, $builder.Capacity)
        $title = $builder.ToString()
        if ($title -like "*DriverVault*") {
            $matches.Add([pscustomobject]@{
                Handle = $handle
                Title  = $title
            }) | Out-Null
        }

        return $true
    }

    [void][DriverVaultNativeCapture]::EnumWindows($callback, [IntPtr]::Zero)
    $match = $matches | Select-Object -First 1
    if ($match) {
        return $match.Handle
    }
    return [IntPtr]::Zero
}

function New-DriverVaultScreenshot {
    param(
        [ValidateSet("ru", "en")]
        [string]$Language
    )

    $outputPath = Join-Path $OutputDirectory ("drivervault-{0}.png" -f $Language)
    $backupPath = Join-Path $env:USERPROFILE ("Desktop\DriverVault_ASUSTeK_COMPUTER_INC._P9X79_LE_20260417_121224")
    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", ('"{0}"' -f $scriptPath),
        "-Mode", "Gui",
        "-Language", $Language,
        "-BackupPath", ('"{0}"' -f $backupPath)
    )

    $process = Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -PassThru
    try {
        $deadline = (Get-Date).AddSeconds($WaitSeconds)
        $handle = [IntPtr]::Zero
        do {
            Start-Sleep -Milliseconds 300
            $process.Refresh()
            $handle = Get-DriverVaultWindowHandle -ProcessId $process.Id
        } while ($handle -eq [IntPtr]::Zero -and (Get-Date) -lt $deadline -and -not $process.HasExited)

        if ($handle -eq [IntPtr]::Zero) {
            throw "DriverVault window did not appear for language '$Language'."
        }

        [DriverVaultNativeCapture]::MoveWindow($handle, 120, 80, 1240, 760, $true) | Out-Null
        Start-Sleep -Milliseconds 700
        Save-WindowScreenshot -Handle $handle -Path $outputPath
        Write-Host "Screenshot written: $outputPath"
    }
    finally {
        if (-not $process.HasExited) {
            try {
                [void]$process.CloseMainWindow()
                if (-not $process.WaitForExit(3000)) {
                    $process.Kill()
                }
            }
            catch {
                Write-Warning $_.Exception.Message
            }
        }
    }
}

New-DriverVaultScreenshot -Language "ru"
New-DriverVaultScreenshot -Language "en"
