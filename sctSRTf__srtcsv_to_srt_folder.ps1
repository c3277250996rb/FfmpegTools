param (
    [Parameter(Mandatory = $true)]
    [string]$path
)

function SecToSrtTime($sec) {

    # 统一转为【整数毫秒】，避免浮点误差
    $totalMs = [long][Math]::Round([double]$sec * 1000)

    $ms = $totalMs % 1000
    $totalSec = ($totalMs - $ms) / 1000

    $s = $totalSec % 60
    $totalMin = ($totalSec - $s) / 60

    $m = $totalMin % 60
    $h = ($totalMin - $m) / 60

    return "{0:D2}:{1:D2}:{2:D2},{3:D3}" -f $h, $m, $s, $ms
}

function Convert-CsvToSrt($csv) {

    Write-Host "转换 $csv"

    $rows = Import-Csv $csv

    # =========================
    # 输出到 csv目录\srt1
    # =========================
    $csvDir = Split-Path $csv
    $outDir = Join-Path $csvDir "srt"

    if (!(Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir | Out-Null
    }

    $name = [System.IO.Path]::GetFileNameWithoutExtension($csv)
    $out  = Join-Path $outDir ($name + ".srt")

    $i = 1
    $lines = @()

    foreach ($r in $rows) {

        $start = [double]$r.start
        $end   = $start + [double]$r.length

        $lines += $i
        $lines += "$(SecToSrtTime $start) --> $(SecToSrtTime $end)"
        $lines += $r.string
        $lines += ""

        $i++
    }

    Set-Content $out -Value $lines -Encoding UTF8
}

# =======================

if (Test-Path $path -PathType Leaf) {
    Convert-CsvToSrt $path
}
elseif (Test-Path $path -PathType Container) {
    Get-ChildItem $path -Filter *.csv | ForEach-Object {
        Convert-CsvToSrt $_.FullName
    }
}
else {
    Write-Host "路径无效"
}
