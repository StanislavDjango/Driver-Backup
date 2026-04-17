param(
    [string]$IconPath = "",
    [string]$PngPath = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

if ([string]::IsNullOrWhiteSpace($IconPath)) {
    $IconPath = Join-Path $root "assets\DriverVault.ico"
}
if ([string]::IsNullOrWhiteSpace($PngPath)) {
    $PngPath = Join-Path $root "assets\DriverVault.png"
}

Add-Type -AssemblyName System.Drawing

function New-RoundedRectanglePath {
    param(
        [System.Drawing.RectangleF]$Rect,
        [float]$Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $arc = New-Object System.Drawing.RectangleF($Rect.X, $Rect.Y, $diameter, $diameter)
    $path.AddArc($arc, 180, 90)
    $arc.X = $Rect.Right - $diameter
    $path.AddArc($arc, 270, 90)
    $arc.Y = $Rect.Bottom - $diameter
    $path.AddArc($arc, 0, 90)
    $arc.X = $Rect.X
    $path.AddArc($arc, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-DriverVaultBitmap {
    param([int]$Size)

    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $scale = $Size / 256.0
    $background = [System.Drawing.RectangleF]::new(16 * $scale, 16 * $scale, 224 * $scale, 224 * $scale)
    $bgPath = New-RoundedRectanglePath -Rect $background -Radius (42 * $scale)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $background,
        [System.Drawing.Color]::FromArgb(255, 18, 32, 52),
        [System.Drawing.Color]::FromArgb(255, 50, 150, 255),
        45
    )
    $graphics.FillPath($bgBrush, $bgPath)

    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(190, 235, 246, 255), [Math]::Max(2, 5 * $scale))
    $graphics.DrawPath($borderPen, $bgPath)

    $vaultRect = [System.Drawing.RectangleF]::new(54 * $scale, 74 * $scale, 148 * $scale, 110 * $scale)
    $vaultPath = New-RoundedRectanglePath -Rect $vaultRect -Radius (16 * $scale)
    $vaultBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 244, 248, 252))
    $graphics.FillPath($vaultBrush, $vaultPath)

    $lidRect = [System.Drawing.RectangleF]::new(76 * $scale, 48 * $scale, 104 * $scale, 46 * $scale)
    $lidPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(245, 244, 248, 252), [Math]::Max(7, 12 * $scale))
    $graphics.DrawArc($lidPen, $lidRect, 200, 140)

    $chipBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 36, 110, 196))
    $chipRect = [System.Drawing.RectangleF]::new(83 * $scale, 96 * $scale, 90 * $scale, 66 * $scale)
    $chipPath = New-RoundedRectanglePath -Rect $chipRect -Radius (10 * $scale)
    $graphics.FillPath($chipBrush, $chipPath)

    $pinPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 185, 221, 255), [Math]::Max(2, 4 * $scale))
    foreach ($x in 96, 116, 136, 156) {
        $graphics.DrawLine($pinPen, $x * $scale, 88 * $scale, $x * $scale, 96 * $scale)
        $graphics.DrawLine($pinPen, $x * $scale, 162 * $scale, $x * $scale, 170 * $scale)
    }
    foreach ($y in 110, 130, 150) {
        $graphics.DrawLine($pinPen, 75 * $scale, $y * $scale, 83 * $scale, $y * $scale)
        $graphics.DrawLine($pinPen, 173 * $scale, $y * $scale, 181 * $scale, $y * $scale)
    }

    $checkPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 50, 213, 131), [Math]::Max(8, 14 * $scale))
    $checkPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $checkPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLines($checkPen, @(
        [System.Drawing.PointF]::new(94 * $scale, 130 * $scale),
        [System.Drawing.PointF]::new(119 * $scale, 154 * $scale),
        [System.Drawing.PointF]::new(162 * $scale, 105 * $scale)
    ))

    foreach ($resource in @($checkPen, $pinPen, $chipBrush, $lidPen, $vaultBrush, $borderPen, $bgBrush, $bgPath, $graphics)) {
        if ($resource -and $resource -is [System.IDisposable]) {
            $resource.Dispose()
        }
    }

    return $bitmap
}

function Convert-BitmapToPngBytes {
    param([System.Drawing.Bitmap]$Bitmap)

    $stream = New-Object System.IO.MemoryStream
    $Bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    return ,$stream.ToArray()
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $IconPath), (Split-Path -Parent $PngPath) | Out-Null

$preview = New-DriverVaultBitmap -Size 512
$preview.Save($PngPath, [System.Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()

$sizes = @(256, 128, 64, 48, 32, 16)
$images = foreach ($size in $sizes) {
    $bitmap = New-DriverVaultBitmap -Size $size
    try {
        [pscustomobject]@{
            Size = $size
            Data = Convert-BitmapToPngBytes -Bitmap $bitmap
        }
    }
    finally {
        $bitmap.Dispose()
    }
}

$fileStream = [System.IO.File]::Create($IconPath)
$writer = New-Object System.IO.BinaryWriter($fileStream)
try {
    $writer.Write([uint16]0)
    $writer.Write([uint16]1)
    $writer.Write([uint16]$images.Count)

    $offset = 6 + ($images.Count * 16)
    foreach ($image in $images) {
        $dimension = if ($image.Size -eq 256) { 0 } else { $image.Size }
        $writer.Write([byte]$dimension)
        $writer.Write([byte]$dimension)
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]$image.Data.Length)
        $writer.Write([uint32]$offset)
        $offset += $image.Data.Length
    }

    foreach ($image in $images) {
        $writer.Write($image.Data)
    }
}
finally {
    $writer.Dispose()
    $fileStream.Dispose()
}

Write-Host "Icon written: $IconPath"
Write-Host "PNG preview written: $PngPath"
