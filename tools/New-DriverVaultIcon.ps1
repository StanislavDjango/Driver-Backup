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

function New-ShieldPath {
    param([float]$Scale)

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $points = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(128 * $Scale, 30 * $Scale),
        [System.Drawing.PointF]::new(199 * $Scale, 58 * $Scale),
        [System.Drawing.PointF]::new(190 * $Scale, 142 * $Scale),
        [System.Drawing.PointF]::new(128 * $Scale, 214 * $Scale),
        [System.Drawing.PointF]::new(66 * $Scale, 142 * $Scale),
        [System.Drawing.PointF]::new(57 * $Scale, 58 * $Scale)
    )
    $path.AddPolygon($points)
    return $path
}

function New-DriverVaultBitmap {
    param([int]$Size)

    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $scale = $Size / 256.0
    $background = [System.Drawing.RectangleF]::new(16 * $scale, 16 * $scale, 224 * $scale, 224 * $scale)
    $bgPath = New-RoundedRectanglePath -Rect $background -Radius (42 * $scale)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $background,
        [System.Drawing.Color]::FromArgb(255, 9, 19, 31),
        [System.Drawing.Color]::FromArgb(255, 18, 82, 105),
        45
    )
    $graphics.FillPath($bgBrush, $bgPath)

    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(210, 229, 244, 250), [Math]::Max(2, 5 * $scale))
    $graphics.DrawPath($borderPen, $bgPath)

    $shieldPath = New-ShieldPath -Scale $scale
    $shieldBounds = [System.Drawing.RectangleF]::new(57 * $scale, 30 * $scale, 142 * $scale, 184 * $scale)
    $shieldBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $shieldBounds,
        [System.Drawing.Color]::FromArgb(255, 42, 202, 190),
        [System.Drawing.Color]::FromArgb(255, 53, 135, 230),
        90
    )
    $graphics.FillPath($shieldBrush, $shieldPath)
    $shieldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(245, 247, 252, 255), [Math]::Max(2, 5 * $scale))
    $graphics.DrawPath($shieldPen, $shieldPath)

    $innerShield = New-ShieldPath -Scale $scale
    $matrix = New-Object System.Drawing.Drawing2D.Matrix
    $matrix.Translate(128 * $scale, 124 * $scale)
    $matrix.Scale(0.78, 0.78)
    $matrix.Translate(-128 * $scale, -124 * $scale)
    $innerShield.Transform($matrix)
    $innerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 255, 255, 255), [Math]::Max(1, 3 * $scale))
    $graphics.DrawPath($innerPen, $innerShield)

    $lidTop = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(74 * $scale, 111 * $scale),
        [System.Drawing.PointF]::new(128 * $scale, 91 * $scale),
        [System.Drawing.PointF]::new(182 * $scale, 111 * $scale),
        [System.Drawing.PointF]::new(163 * $scale, 130 * $scale),
        [System.Drawing.PointF]::new(93 * $scale, 130 * $scale)
    )
    $boxLidBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 238, 190, 83))
    $boxLidPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(210, 35, 45, 58), [Math]::Max(1, 3 * $scale))
    $graphics.FillPolygon($boxLidBrush, $lidTop)
    $graphics.DrawPolygon($boxLidPen, $lidTop)

    $boxRect = [System.Drawing.RectangleF]::new(73 * $scale, 124 * $scale, 110 * $scale, 65 * $scale)
    $boxPath = New-RoundedRectanglePath -Rect $boxRect -Radius (9 * $scale)
    $boxBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $boxRect,
        [System.Drawing.Color]::FromArgb(255, 252, 253, 255),
        [System.Drawing.Color]::FromArgb(255, 215, 228, 237),
        90
    )
    $boxPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(225, 35, 45, 58), [Math]::Max(1, 3 * $scale))
    $graphics.FillPath($boxBrush, $boxPath)
    $graphics.DrawPath($boxPen, $boxPath)

    $tapeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 72, 185, 211))
    $graphics.FillRectangle($tapeBrush, [System.Drawing.RectangleF]::new(119 * $scale, 124 * $scale, 18 * $scale, 65 * $scale))

    $seamPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 91, 113, 129), [Math]::Max(1, 2 * $scale))
    $graphics.DrawLine($seamPen, 75 * $scale, 149 * $scale, 181 * $scale, 149 * $scale)

    $chipRect = [System.Drawing.RectangleF]::new(96 * $scale, 137 * $scale, 64 * $scale, 44 * $scale)
    $chipPath = New-RoundedRectanglePath -Rect $chipRect -Radius (7 * $scale)
    $chipBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 42, 63))
    $chipPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 111, 231, 209), [Math]::Max(1, 3 * $scale))
    $graphics.FillPath($chipBrush, $chipPath)
    $graphics.DrawPath($chipPen, $chipPath)

    $pinPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 191, 242, 231), [Math]::Max(1, 3 * $scale))
    foreach ($x in 106, 120, 134, 148) {
        $graphics.DrawLine($pinPen, $x * $scale, 130 * $scale, $x * $scale, 137 * $scale)
        $graphics.DrawLine($pinPen, $x * $scale, 181 * $scale, $x * $scale, 188 * $scale)
    }
    foreach ($y in 148, 160, 172) {
        $graphics.DrawLine($pinPen, 89 * $scale, $y * $scale, 96 * $scale, $y * $scale)
        $graphics.DrawLine($pinPen, 160 * $scale, $y * $scale, 167 * $scale, $y * $scale)
    }

    $chipLinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 55, 224, 134), [Math]::Max(2, 5 * $scale))
    $chipLinePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $chipLinePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLines($chipLinePen, [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(110 * $scale, 160 * $scale),
        [System.Drawing.PointF]::new(124 * $scale, 172 * $scale),
        [System.Drawing.PointF]::new(147 * $scale, 147 * $scale)
    ))

    $highlightPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, 255, 255, 255), [Math]::Max(2, 4 * $scale))
    $highlightPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $highlightPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine($highlightPen, 82 * $scale, 59 * $scale, 128 * $scale, 42 * $scale)

    foreach ($resource in @(
        $highlightPen, $chipLinePen, $pinPen, $chipPen, $chipBrush, $chipPath,
        $seamPen, $tapeBrush, $boxPen, $boxBrush, $boxPath, $boxLidPen, $boxLidBrush,
        $innerPen, $matrix, $innerShield, $shieldPen, $shieldBrush, $shieldPath,
        $borderPen, $bgBrush, $bgPath, $graphics
    )) {
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
