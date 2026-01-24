param (
    [string]$srtFile
)

if (-not (Test-Path $srtFile)) {
    Write-Host "找不到 SRT 文件"
    exit
}

# ========================
# 时间解析
# ========================
function Parse-Time($t) {
    if ($t -match '^(\d{2}):(\d{2}):(\d{2})(?:,(\d{1,3}))?$') {
        $h = [int]$matches[1]
        $m = [int]$matches[2]
        $s = [int]$matches[3]
        $ms = if ($matches[4]) { [int]$matches[4].PadRight(3,'0') } else { 0 }
        return ($h * 3600000 + $m * 60000 + $s * 1000 + $ms)
    }
    throw "无法解析时间：$t"
}

function Format-Time($ms) {
    if ($ms -lt 0) { $ms = 0 }
    $h = [math]::Floor($ms / 3600000)
    $m = [math]::Floor(($ms % 3600000) / 60000)
    $s = [math]::Floor(($ms % 60000) / 1000)
    $f = $ms % 1000
    return "{0:00}:{1:00}:{2:00},{3:000}" -f $h,$m,$s,$f
}

# ========================
# 读取字幕
# ========================
$lines = Get-Content $srtFile -Encoding UTF8

$subs = @()
$i = 0
while ($i -lt $lines.Count) {
    if ($lines[$i] -match '^\d+$') {
        $index = $lines[$i]
        $time = $lines[$i+1]
        $text = @()
        $i += 2
        while ($i -lt $lines.Count -and $lines[$i] -ne "") {
            $text += $lines[$i]
            $i++
        }

        if ($time -match '(.*) --> (.*)') {
            $subs += [PSCustomObject]@{
                start = Parse-Time $matches[1]
                end   = Parse-Time $matches[2]
                text  = $text
            }
        }
    }
    $i++
}

$endTime = ($subs | Measure-Object end -Maximum).Maximum
Write-Host "字幕结尾时间：" (Format-Time $endTime)

# ========================
# 输入分割时间点
# ========================
Write-Host ""
Write-Host "请输入分割时间点（回车分隔）（可以,但是尽量不要带小数）："

$cuts = @()
while ($true) {
    $t = Read-Host
    if ($t -eq "") { break }
    $cuts += Parse-Time $t
}

$cuts = $cuts | Sort-Object
$cuts = ,0 + $cuts + $endTime

# ========================
# 分割
# ========================
$base = [IO.Path]::GetFileNameWithoutExtension($srtFile)
$dir  = Split-Path $srtFile

for ($i = 0; $i -lt $cuts.Count - 1; $i++) {

    $start = $cuts[$i]
    $end   = $cuts[$i + 1]

    $part = $subs | Where-Object {
        $_.end -gt $start -and $_.start -lt $end
    }

    if ($part.Count -eq 0) { continue }

    $out = @()
    $n = 1

    foreach ($s in $part) {
        $ns = $s.start - $start
        $ne = $s.end   - $start

        $out += $n
        $out += "$(Format-Time $ns) --> $(Format-Time $ne)"
        $out += $s.text
        $out += ""
        $n++
    }

    $outfile = Join-Path $dir ("{0}_part{1}.srt" -f $base, ($i+1))
    $out | Set-Content $outfile -Encoding UTF8

    Write-Host "生成：" $outfile
}

Write-Host "完成"
