param (
    [Parameter(Mandatory = $true)]
    [string]$subtitleCsv,

    [Parameter(Mandatory = $true)]
    [string]$cutCsv
)

function HMS_to_sec($t) {
    if ($t -match '^(\d{2}):(\d{2}):(\d{2})$') {
        return ([int]$matches[1] * 3600) +
               ([int]$matches[2] * 60) +
               ([int]$matches[3])
    }
    return 0
}

function sec_to_HMS($s) {
    $h = [int]($s / 3600)
    $m = [int](($s % 3600) / 60)
    $sec = [int]($s % 60)
    return "{0:D2}-{1:D2}-{2:D2}" -f $h, $m, $sec
}

# ========= 文件名 =========
$base = [System.IO.Path]::GetFileNameWithoutExtension($cutCsv)
$outdir = $base
if (!(Test-Path $outdir)) {
    New-Item -ItemType Directory $outdir | Out-Null
}

# ========= 读取字幕 =========
$subs = Import-Csv $subtitleCsv

# ========= 读取切点 =========
$cutsRaw = Import-Csv $cutCsv -Header no,title,time -Encoding Default

$cuts = @()
foreach ($c in $cutsRaw) {
    $cuts += [PSCustomObject]@{
        title = $c.title
        sec   = HMS_to_sec $c.time
        time  = $c.time
    }
}

# ========= 构造 n+1 段 =========
$segments = @()

# 第一段：开头
$segments += [PSCustomObject]@{
    title = "开头"
    start = 0
    end   = $cuts[0].sec
    st    = "00-00-00"
    et    = ($cuts[0].time -replace ":", "-")
}

# 中间段
for ($i = 0; $i -lt $cuts.Count - 1; $i++) {
    $segments += [PSCustomObject]@{
        title = $cuts[$i].title
        start = $cuts[$i].sec
        end   = $cuts[$i + 1].sec
        st    = ($cuts[$i].time -replace ":", "-")
        et    = ($cuts[$i + 1].time -replace ":", "-")
    }
}

# 最后一段
$segments += [PSCustomObject]@{
    title = $cuts[-1].title
    start = $cuts[-1].sec
    end   = 999999
    st    = ($cuts[-1].time -replace ":", "-")
    et    = "结束"
}

# ========= 分割字幕 =========
$idx = 1

foreach ($seg in $segments) {

    $part = $subs | Where-Object {
        ([double]$_.start -ge $seg.start) -and
        ([double]$_.start -lt $seg.end)
    }

    if ($part.Count -eq 0) {
        $idx++
        continue
    }

    foreach ($s in $part) {
        $s.start = "{0:F3}" -f ([double]$s.start - $seg.start)
    }

    $no = "{0:D2}" -f $idx

    $outfile = "{0}_{1}_{2}_({3}_{4}).csv" -f `
        $base,
        "($no)",
        $seg.title,
        $seg.st,
        $seg.et

    $path = Join-Path $outdir $outfile

    $part | Export-Csv $path -Encoding UTF8 -NoTypeInformation

    Write-Host "生成 $path"
    $idx++
}
